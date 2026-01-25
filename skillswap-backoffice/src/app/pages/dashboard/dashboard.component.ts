import { Component } from '@angular/core';
import { CommonModule } from '@angular/common';
import { Router, RouterModule } from '@angular/router';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-dashboard',
  imports: [CommonModule, RouterModule],
  template: `
    <div class="dashboard">
      <nav class="navbar">
        <div class="nav-brand">
          <div class="logo-icon">
            <svg width="32" height="32" viewBox="0 0 48 48" fill="none">
              <rect width="48" height="48" rx="10" fill="url(#gradient)"/>
              <path d="M24 14L18 20H22V28H26V20H30L24 14Z" fill="white"/>
              <path d="M24 34L30 28H26V20H22V28H18L24 34Z" fill="white" opacity="0.7"/>
              <defs>
                <linearGradient id="gradient" x1="0" y1="0" x2="48" y2="48">
                  <stop offset="0%" stop-color="#667eea"/>
                  <stop offset="100%" stop-color="#764ba2"/>
                </linearGradient>
              </defs>
            </svg>
          </div>
          <div>
            <h2>SkillSwap</h2>
            <span class="nav-subtitle">Admin Panel</span>
          </div>
        </div>
        <div class="nav-user">
          <div class="user-info">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"/>
            </svg>
            <span>{{ authService.currentUser()?.email }}</span>
          </div>
          <button (click)="logout()" class="btn-logout">
            <svg width="18" height="18" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M3 3a1 1 0 00-1 1v12a1 1 0 102 0V4a1 1 0 00-1-1zm10.293 9.293a1 1 0 001.414 1.414l3-3a1 1 0 000-1.414l-3-3a1 1 0 10-1.414 1.414L14.586 9H7a1 1 0 100 2h7.586l-1.293 1.293z"/>
            </svg>
            Logout
          </button>
        </div>
      </nav>

      <div class="dashboard-content">
        <aside class="sidebar">
          <a routerLink="/dashboard/overview" routerLinkActive="active" class="menu-item">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
              <path d="M3 4a1 1 0 011-1h12a1 1 0 011 1v2a1 1 0 01-1 1H4a1 1 0 01-1-1V4zM3 10a1 1 0 011-1h6a1 1 0 011 1v6a1 1 0 01-1 1H4a1 1 0 01-1-1v-6zM14 9a1 1 0 00-1 1v6a1 1 0 001 1h2a1 1 0 001-1v-6a1 1 0 00-1-1h-2z"/>
            </svg>
            <span>Overview</span>
          </a>
          <a routerLink="/dashboard/users" routerLinkActive="active" class="menu-item">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
              <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"/>
            </svg>
            <span>Users</span>
          </a>
          <a routerLink="/dashboard/partner-places" routerLinkActive="active" class="menu-item">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z"/>
            </svg>
            <span>Partner Places</span>
          </a>
          <a routerLink="/dashboard/disputes" routerLinkActive="active" class="menu-item">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7 4a1 1 0 11-2 0 1 1 0 012 0zm-1-9a1 1 0 00-1 1v4a1 1 0 102 0V6a1 1 0 00-1-1z"/>
            </svg>
            <span>Disputes</span>
          </a>
        </aside>

        <main class="main-content">
          <router-outlet></router-outlet>
        </main>
      </div>
    </div>
  `,
  styles: [`
    .dashboard {
      min-height: 100vh;
      background: #f7fafc;
    }

    .navbar {
      background: white;
      padding: 16px 32px;
      box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
      display: flex;
      justify-content: space-between;
      align-items: center;
      position: sticky;
      top: 0;
      z-index: 100;
    }

    .nav-brand {
      display: flex;
      align-items: center;
      gap: 16px;
    }

    .logo-icon svg {
      display: block;
    }

    .nav-brand h2 {
      margin: 0;
      color: #1a202c;
      font-size: 20px;
      font-weight: 700;
      letter-spacing: -0.5px;
    }

    .nav-subtitle {
      color: #718096;
      font-size: 12px;
      font-weight: 500;
    }

    .nav-user {
      display: flex;
      align-items: center;
      gap: 20px;
    }

    .user-info {
      display: flex;
      align-items: center;
      gap: 8px;
      color: #4a5568;
      font-size: 14px;
      font-weight: 500;
    }

    .user-info svg {
      color: #667eea;
    }

    .btn-logout {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 20px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      border-radius: 10px;
      cursor: pointer;
      font-size: 14px;
      font-weight: 600;
      transition: all 0.3s ease;
      box-shadow: 0 2px 8px rgba(102, 126, 234, 0.3);
    }

    .btn-logout:hover {
      transform: translateY(-2px);
      box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
    }

    .dashboard-content {
      display: flex;
      min-height: calc(100vh - 72px);
    }

    .sidebar {
      width: 280px;
      background: white;
      padding: 24px 0;
      box-shadow: 1px 0 3px rgba(0, 0, 0, 0.05);
    }

    .menu-item {
      display: flex;
      align-items: center;
      gap: 14px;
      padding: 14px 28px;
      color: #4a5568;
      text-decoration: none;
      transition: all 0.3s ease;
      font-weight: 500;
      font-size: 15px;
      border-left: 3px solid transparent;
    }

    .menu-item svg {
      flex-shrink: 0;
    }

    .menu-item:hover {
      background: #f7fafc;
      color: #667eea;
      border-left-color: #e2e8f0;
    }

    .menu-item.active {
      background: linear-gradient(90deg, rgba(102, 126, 234, 0.1) 0%, transparent 100%);
      color: #667eea;
      border-left-color: #667eea;
      font-weight: 600;
    }

    .main-content {
      flex: 1;
      padding: 32px;
      overflow-x: hidden;
    }

    @media (max-width: 768px) {
      .navbar {
        padding: 12px 16px;
      }

      .nav-brand h2 {
        font-size: 18px;
      }

      .nav-subtitle {
        display: none;
      }

      .user-info span {
        display: none;
      }

      .sidebar {
        width: 70px;
        padding: 16px 0;
      }

      .menu-item {
        padding: 14px 20px;
        justify-content: center;
      }

      .menu-item span {
        display: none;
      }

      .main-content {
        padding: 20px;
      }
    }
  `]
})
export class DashboardComponent {
  constructor(
    public authService: AuthService,
    private router: Router
  ) {}

  logout(): void {
    this.authService.logout();
  }
}
