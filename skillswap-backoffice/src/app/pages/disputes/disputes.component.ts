import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';

interface Dispute {
  id: string;
  missionId: string;
  missionTitle: string;
  reportedBy: string;
  reportedAgainst: string;
  reason: string;
  status: 'PENDING' | 'INVESTIGATING' | 'RESOLVED' | 'REJECTED';
  priority: 'LOW' | 'MEDIUM' | 'HIGH';
  createdAt: Date;
  description: string;
}

@Component({
  selector: 'app-disputes',
  imports: [CommonModule, FormsModule],
  template: `
    <div class="disputes-page">
      <div class="page-header">
        <div>
          <h1>Dispute Management</h1>
          <p>Review and resolve user disputes</p>
        </div>
        <div class="header-actions">
          <select class="filter-select" [(ngModel)]="selectedFilter" (change)="filterDisputes()">
            <option value="all">All Disputes</option>
            <option value="PENDING">Pending</option>
            <option value="INVESTIGATING">Investigating</option>
            <option value="RESOLVED">Resolved</option>
          </select>
        </div>
      </div>

      <!-- Stats -->
      <div class="dispute-stats">
        <div class="stat-item">
          <span class="stat-number">{{ getCountByStatus('PENDING') }}</span>
          <span class="stat-label">Pending</span>
        </div>
        <div class="stat-item">
          <span class="stat-number">{{ getCountByStatus('INVESTIGATING') }}</span>
          <span class="stat-label">Investigating</span>
        </div>
        <div class="stat-item">
          <span class="stat-number">{{ getCountByStatus('RESOLVED') }}</span>
          <span class="stat-label">Resolved</span>
        </div>
        <div class="stat-item">
          <span class="stat-number">{{ getCountByStatus('REJECTED') }}</span>
          <span class="stat-label">Rejected</span>
        </div>
      </div>

      <!-- Disputes List -->
      <div class="disputes-list">
        @for (dispute of filteredDisputes(); track dispute.id) {
          <div class="dispute-card" [class.expanded]="selectedDispute()?.id === dispute.id">
            <div class="dispute-header" (click)="selectDispute(dispute)">
              <div class="dispute-info">
                <div class="dispute-title">
                  <h3>{{ dispute.missionTitle }}</h3>
                  <span class="dispute-id">#{{ dispute.id }}</span>
                </div>
                <div class="dispute-meta">
                  <span class="meta-item">
                    <svg width="14" height="14" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"/>
                    </svg>
                    {{ dispute.reportedBy }}
                  </span>
                  <span class="meta-item">
                    <svg width="14" height="14" viewBox="0 0 20 20" fill="currentColor">
                      <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zm1-12a1 1 0 10-2 0v4a1 1 0 00.293.707l2.828 2.829a1 1 0 101.415-1.415L11 9.586V6z"/>
                    </svg>
                    {{ formatDate(dispute.createdAt) }}
                  </span>
                </div>
              </div>
              <div class="dispute-badges">
                <span class="badge priority" [class]="dispute.priority.toLowerCase()">
                  {{ dispute.priority }}
                </span>
                <span class="badge status" [class]="dispute.status.toLowerCase()">
                  {{ dispute.status }}
                </span>
              </div>
            </div>

            @if (selectedDispute()?.id === dispute.id) {
              <div class="dispute-details">
                <div class="detail-section">
                  <h4>Dispute Details</h4>
                  <div class="detail-grid">
                    <div class="detail-item">
                      <span class="detail-label">Mission ID:</span>
                      <span class="detail-value">{{ dispute.missionId }}</span>
                    </div>
                    <div class="detail-item">
                      <span class="detail-label">Reported By:</span>
                      <span class="detail-value">{{ dispute.reportedBy }}</span>
                    </div>
                    <div class="detail-item">
                      <span class="detail-label">Reported Against:</span>
                      <span class="detail-value">{{ dispute.reportedAgainst }}</span>
                    </div>
                    <div class="detail-item">
                      <span class="detail-label">Reason:</span>
                      <span class="detail-value">{{ dispute.reason }}</span>
                    </div>
                  </div>
                  <div class="detail-description">
                    <span class="detail-label">Description:</span>
                    <p>{{ dispute.description }}</p>
                  </div>
                </div>

                <div class="detail-actions">
                  <button class="btn btn-secondary" (click)="updateStatus(dispute, 'INVESTIGATING')">
                    Mark as Investigating
                  </button>
                  <button class="btn btn-success" (click)="updateStatus(dispute, 'RESOLVED')">
                    Resolve Dispute
                  </button>
                  <button class="btn btn-danger" (click)="updateStatus(dispute, 'REJECTED')">
                    Reject Dispute
                  </button>
                </div>
              </div>
            }
          </div>
        } @empty {
          <div class="empty-state">
            <svg width="64" height="64" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"/>
            </svg>
            <h3>No disputes found</h3>
            <p>There are no disputes matching your filter criteria</p>
          </div>
        }
      </div>
    </div>
  `,
  styles: [`
    .disputes-page {
      max-width: 1200px;
    }

    .page-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 24px;
    }

    .page-header h1 {
      margin: 0 0 8px 0;
      font-size: 28px;
      font-weight: 700;
      color: #1a202c;
    }

    .page-header p {
      margin: 0;
      color: #718096;
      font-size: 14px;
    }

    .filter-select {
      padding: 10px 16px;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      font-size: 14px;
      color: #4a5568;
      background: white;
      cursor: pointer;
    }

    .dispute-stats {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(150px, 1fr));
      gap: 16px;
      margin-bottom: 24px;
    }

    .stat-item {
      background: white;
      border: 1px solid #e2e8f0;
      border-radius: 10px;
      padding: 20px;
      text-align: center;
    }

    .stat-number {
      display: block;
      font-size: 32px;
      font-weight: 700;
      color: #1a202c;
      margin-bottom: 4px;
    }

    .stat-label {
      display: block;
      font-size: 13px;
      color: #718096;
      font-weight: 500;
    }

    .disputes-list {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    .dispute-card {
      background: white;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
      overflow: hidden;
      transition: all 0.2s;
    }

    .dispute-card:hover {
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
    }

    .dispute-card.expanded {
      border-color: #667eea;
    }

    .dispute-header {
      padding: 20px;
      display: flex;
      justify-content: space-between;
      align-items: center;
      cursor: pointer;
    }

    .dispute-info {
      flex: 1;
    }

    .dispute-title {
      display: flex;
      align-items: center;
      gap: 12px;
      margin-bottom: 8px;
    }

    .dispute-title h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
      color: #1a202c;
    }

    .dispute-id {
      font-size: 12px;
      color: #a0aec0;
      font-weight: 500;
    }

    .dispute-meta {
      display: flex;
      gap: 16px;
    }

    .meta-item {
      display: flex;
      align-items: center;
      gap: 6px;
      font-size: 13px;
      color: #718096;
    }

    .meta-item svg {
      color: #a0aec0;
    }

    .dispute-badges {
      display: flex;
      gap: 8px;
    }

    .badge {
      padding: 6px 12px;
      border-radius: 6px;
      font-size: 12px;
      font-weight: 600;
      text-transform: uppercase;
    }

    .badge.priority.high {
      background: #fff5f5;
      color: #c53030;
    }

    .badge.priority.medium {
      background: #fffaf0;
      color: #c05621;
    }

    .badge.priority.low {
      background: #f0fff4;
      color: #276749;
    }

    .badge.status.pending {
      background: #fffaf0;
      color: #c05621;
    }

    .badge.status.investigating {
      background: #ebf8ff;
      color: #2c5282;
    }

    .badge.status.resolved {
      background: #f0fff4;
      color: #276749;
    }

    .badge.status.rejected {
      background: #fff5f5;
      color: #c53030;
    }

    .dispute-details {
      border-top: 1px solid #e2e8f0;
      padding: 20px;
      background: #f7fafc;
    }

    .detail-section {
      margin-bottom: 20px;
    }

    .detail-section h4 {
      margin: 0 0 16px 0;
      font-size: 14px;
      font-weight: 600;
      color: #1a202c;
      text-transform: uppercase;
      letter-spacing: 0.5px;
    }

    .detail-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(200px, 1fr));
      gap: 16px;
      margin-bottom: 16px;
    }

    .detail-item {
      display: flex;
      flex-direction: column;
      gap: 4px;
    }

    .detail-label {
      font-size: 12px;
      color: #718096;
      font-weight: 500;
    }

    .detail-value {
      font-size: 14px;
      color: #2d3748;
      font-weight: 500;
    }

    .detail-description {
      margin-top: 16px;
    }

    .detail-description p {
      margin: 8px 0 0 0;
      font-size: 14px;
      color: #4a5568;
      line-height: 1.6;
    }

    .detail-actions {
      display: flex;
      gap: 12px;
      flex-wrap: wrap;
    }

    .btn {
      padding: 10px 20px;
      border: none;
      border-radius: 8px;
      font-size: 14px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.2s;
    }

    .btn-secondary {
      background: #edf2f7;
      color: #4a5568;
    }

    .btn-secondary:hover {
      background: #e2e8f0;
    }

    .btn-success {
      background: #48bb78;
      color: white;
    }

    .btn-success:hover {
      background: #38a169;
    }

    .btn-danger {
      background: #f56565;
      color: white;
    }

    .btn-danger:hover {
      background: #e53e3e;
    }

    .empty-state {
      text-align: center;
      padding: 60px 20px;
      background: white;
      border: 1px solid #e2e8f0;
      border-radius: 12px;
    }

    .empty-state svg {
      color: #cbd5e0;
      margin-bottom: 16px;
    }

    .empty-state h3 {
      margin: 0 0 8px 0;
      font-size: 18px;
      color: #2d3748;
    }

    .empty-state p {
      margin: 0;
      color: #718096;
      font-size: 14px;
    }
  `]
})
export class DisputesComponent implements OnInit {
  disputes = signal<Dispute[]>([]);
  filteredDisputes = signal<Dispute[]>([]);
  selectedDispute = signal<Dispute | null>(null);
  selectedFilter = 'all';

  ngOnInit(): void {
    this.loadDisputes();
  }

  loadDisputes(): void {
    // Demo data - replace with API call
    const demoDisputes: Dispute[] = [
      {
        id: 'DSP001',
        missionId: 'MSN123',
        missionTitle: 'Guitar Lessons',
        reportedBy: 'john@example.com',
        reportedAgainst: 'sarah@example.com',
        reason: 'Service not provided',
        status: 'PENDING',
        priority: 'HIGH',
        createdAt: new Date(Date.now() - 2 * 60 * 60 * 1000),
        description: 'The provider did not show up at the agreed time and place. I waited for 30 minutes but received no communication.'
      },
      {
        id: 'DSP002',
        missionId: 'MSN124',
        missionTitle: 'Web Development',
        reportedBy: 'mike@example.com',
        reportedAgainst: 'lisa@example.com',
        reason: 'Quality issues',
        status: 'INVESTIGATING',
        priority: 'MEDIUM',
        createdAt: new Date(Date.now() - 5 * 60 * 60 * 1000),
        description: 'The work delivered does not match the agreed specifications. Several features are missing.'
      },
      {
        id: 'DSP003',
        missionId: 'MSN125',
        missionTitle: 'Photography Session',
        reportedBy: 'emma@example.com',
        reportedAgainst: 'david@example.com',
        reason: 'Payment dispute',
        status: 'RESOLVED',
        priority: 'LOW',
        createdAt: new Date(Date.now() - 24 * 60 * 60 * 1000),
        description: 'Credits were not transferred after mission completion. Issue has been resolved.'
      }
    ];

    this.disputes.set(demoDisputes);
    this.filteredDisputes.set(demoDisputes);
  }

  filterDisputes(): void {
    if (this.selectedFilter === 'all') {
      this.filteredDisputes.set(this.disputes());
    } else {
      this.filteredDisputes.set(
        this.disputes().filter(d => d.status === this.selectedFilter)
      );
    }
  }

  selectDispute(dispute: Dispute): void {
    if (this.selectedDispute()?.id === dispute.id) {
      this.selectedDispute.set(null);
    } else {
      this.selectedDispute.set(dispute);
    }
  }

  updateStatus(dispute: Dispute, newStatus: Dispute['status']): void {
    const updated = this.disputes().map(d =>
      d.id === dispute.id ? { ...d, status: newStatus } : d
    );
    this.disputes.set(updated);
    this.filterDisputes();
    this.selectedDispute.set(null);
    alert(`Dispute ${dispute.id} status updated to ${newStatus}`);
  }

  getCountByStatus(status: string): number {
    return this.disputes().filter(d => d.status === status).length;
  }

  formatDate(date: Date): string {
    const now = new Date();
    const diff = now.getTime() - date.getTime();
    const hours = Math.floor(diff / (1000 * 60 * 60));
    
    if (hours < 1) return 'Just now';
    if (hours < 24) return `${hours}h ago`;
    const days = Math.floor(hours / 24);
    return `${days}d ago`;
  }
}
