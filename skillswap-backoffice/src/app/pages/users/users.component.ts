import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService, User } from '../../services/api.service';

@Component({
  selector: 'app-users',
  imports: [CommonModule],
  template: `
    <div class="users-page">
      <div class="page-header">
        <h1>Users Management</h1>
        <button (click)="loadUsers()" class="btn-refresh">
          🔄 Refresh
        </button>
      </div>

      @if (loading()) {
        <div class="loading">Loading users...</div>
      }

      @if (error()) {
        <div class="error-message">{{ error() }}</div>
      }

      @if (!loading() && users().length > 0) {
        <div class="stats">
          <div class="stat-card">
            <div class="stat-value">{{ users().length }}</div>
            <div class="stat-label">Total Users</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">{{ getTotalCredits() }}</div>
            <div class="stat-label">Total Credits</div>
          </div>
          <div class="stat-card">
            <div class="stat-value">{{ getAverageScore() }}</div>
            <div class="stat-label">Avg Helper Score</div>
          </div>
        </div>

        <div class="table-container">
          <table class="users-table">
            <thead>
              <tr>
                <th>Name</th>
                <th>Email</th>
                <th>Phone</th>
                <th>Credits</th>
                <th>Helper Score</th>
                <th>Role</th>
              </tr>
            </thead>
            <tbody>
              @for (user of users(); track user.userId) {
                <tr>
                  <td>{{ user.fullName || 'N/A' }}</td>
                  <td>{{ user.email }}</td>
                  <td>{{ user.phoneNumber || 'N/A' }}</td>
                  <td>
                    <span class="badge badge-credits">{{ user.creditsBalance }}</span>
                  </td>
                  <td>
                    <span class="badge badge-score">{{ user.helperScore.toFixed(1) }}</span>
                  </td>
                  <td>
                    <span class="badge" [class.badge-admin]="isAdmin(user)">
                      {{ getRoleDisplay(user) }}
                    </span>
                  </td>
                </tr>
              }
            </tbody>
          </table>
        </div>
      }

      @if (!loading() && users().length === 0 && !error()) {
        <div class="empty-state">
          <p>No users found</p>
        </div>
      }
    </div>
  `,
  styles: [`
    .users-page {
      background: white;
      border-radius: 8px;
      padding: 24px;
      box-shadow: 0 2px 4px rgba(0, 0, 0, 0.1);
    }

    .page-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 24px;
    }

    .page-header h1 {
      margin: 0;
      color: #333;
    }

    .btn-refresh {
      padding: 10px 20px;
      background: #667eea;
      color: white;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
    }

    .btn-refresh:hover {
      background: #5568d3;
    }

    .stats {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }

    .stat-card {
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      padding: 20px;
      border-radius: 8px;
      text-align: center;
    }

    .stat-value {
      font-size: 32px;
      font-weight: bold;
      margin-bottom: 8px;
    }

    .stat-label {
      font-size: 14px;
      opacity: 0.9;
    }

    .table-container {
      overflow-x: auto;
    }

    .users-table {
      width: 100%;
      border-collapse: collapse;
    }

    .users-table th {
      background: #f5f5f5;
      padding: 12px;
      text-align: left;
      font-weight: 600;
      color: #666;
      border-bottom: 2px solid #ddd;
    }

    .users-table td {
      padding: 12px;
      border-bottom: 1px solid #eee;
    }

    .users-table tr:hover {
      background: #f9f9f9;
    }

    .badge {
      display: inline-block;
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 600;
    }

    .badge-credits {
      background: #e3f2fd;
      color: #1976d2;
    }

    .badge-score {
      background: #f3e5f5;
      color: #7b1fa2;
    }

    .badge-admin {
      background: #ffebee;
      color: #c62828;
    }

    .loading, .empty-state {
      text-align: center;
      padding: 40px;
      color: #666;
    }

    .error-message {
      background: #fee;
      color: #c33;
      padding: 12px;
      border-radius: 6px;
      margin-bottom: 20px;
    }
  `]
})
export class UsersComponent implements OnInit {
  users = signal<User[]>([]);
  loading = signal(false);
  error = signal('');

  constructor(private apiService: ApiService) { }

  ngOnInit(): void {
    this.loadUsers();
  }

  loadUsers(): void {
    this.loading.set(true);
    this.error.set('');

    this.apiService.getAllUsers().subscribe({
      next: (data) => {
        this.users.set(data);
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set('Failed to load users. Make sure the backend is running.');
        this.loading.set(false);
        console.error('Error loading users:', err);
      }
    });
  }

  getTotalCredits(): number {
    return this.users().reduce((sum, user) => sum + (user.creditsBalance || 0), 0);
  }

  getAverageScore(): string {
    const users = this.users();
    if (users.length === 0) return '0';
    const avg = users.reduce((sum, user) => sum + (user.helperScore || 0), 0) / users.length;
    return avg.toFixed(1);
  }

  isAdmin(user: User): boolean {
    return user.roles?.includes('ADMIN') ?? false;
  }

  getRoleDisplay(user: User): string {
    if (!user.roles || user.roles.length === 0) return 'USER';
    return user.roles.join(', ');
  }
}
