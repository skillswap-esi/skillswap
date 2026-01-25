import { Component, OnInit, AfterViewInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { ApiService } from '../../services/api.service';

declare var Chart: any;

@Component({
  selector: 'app-overview',
  imports: [CommonModule],
  template: `
    <div class="overview-page">
      <div class="page-header">
        <div>
          <h1>Dashboard Overview</h1>
          <p>Monitor your platform's key metrics and performance</p>
        </div>
        <button (click)="refreshData()" class="btn-refresh">
          <svg width="18" height="18" viewBox="0 0 20 20" fill="currentColor">
            <path fill-rule="evenodd" d="M4 2a1 1 0 011 1v2.101a7.002 7.002 0 0111.601 2.566 1 1 0 11-1.885.666A5.002 5.002 0 005.999 7H9a1 1 0 010 2H4a1 1 0 01-1-1V3a1 1 0 011-1zm.008 9.057a1 1 0 011.276.61A5.002 5.002 0 0014.001 13H11a1 1 0 110-2h5a1 1 0 011 1v5a1 1 0 11-2 0v-2.101a7.002 7.002 0 01-11.601-2.566 1 1 0 01.61-1.276z"/>
          </svg>
          Refresh
        </button>
      </div>

      <!-- Stats Cards -->
      <div class="stats-grid">
        <div class="stat-card">
          <div class="stat-icon blue">
            <svg width="24" height="24" viewBox="0 0 20 20" fill="currentColor">
              <path d="M9 6a3 3 0 11-6 0 3 3 0 016 0zM17 6a3 3 0 11-6 0 3 3 0 016 0zM12.93 17c.046-.327.07-.66.07-1a6.97 6.97 0 00-1.5-4.33A5 5 0 0119 16v1h-6.07zM6 11a5 5 0 015 5v1H1v-1a5 5 0 015-5z"/>
            </svg>
          </div>
          <div class="stat-content">
            <p class="stat-label">Total Users</p>
            <h3 class="stat-value">{{ stats().totalUsers }}</h3>
            <p class="stat-change positive">+12% from last month</p>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon green">
            <svg width="24" height="24" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"/>
            </svg>
          </div>
          <div class="stat-content">
            <p class="stat-label">Active Missions</p>
            <h3 class="stat-value">{{ stats().activeMissions }}</h3>
            <p class="stat-change positive">+8% from last week</p>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon purple">
            <svg width="24" height="24" viewBox="0 0 20 20" fill="currentColor">
              <path d="M2 11a1 1 0 011-1h2a1 1 0 011 1v5a1 1 0 01-1 1H3a1 1 0 01-1-1v-5zM8 7a1 1 0 011-1h2a1 1 0 011 1v9a1 1 0 01-1 1H9a1 1 0 01-1-1V7zM14 4a1 1 0 011-1h2a1 1 0 011 1v12a1 1 0 01-1 1h-2a1 1 0 01-1-1V4z"/>
            </svg>
          </div>
          <div class="stat-content">
            <p class="stat-label">Total Skills</p>
            <h3 class="stat-value">{{ stats().totalSkills }}</h3>
            <p class="stat-change positive">+15% from last month</p>
          </div>
        </div>

        <div class="stat-card">
          <div class="stat-icon orange">
            <svg width="24" height="24" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M5.05 4.05a7 7 0 119.9 9.9L10 18.9l-4.95-4.95a7 7 0 010-9.9zM10 11a2 2 0 100-4 2 2 0 000 4z"/>
            </svg>
          </div>
          <div class="stat-content">
            <p class="stat-label">Partner Places</p>
            <h3 class="stat-value">{{ stats().partnerPlaces }}</h3>
            <p class="stat-change neutral">No change</p>
          </div>
        </div>
      </div>

      <!-- Charts Row -->
      <div class="charts-row">
        <div class="chart-card">
          <div class="chart-header">
            <h3>User Growth</h3>
            <select class="chart-filter">
              <option>Last 7 days</option>
              <option>Last 30 days</option>
              <option>Last 90 days</option>
            </select>
          </div>
          <canvas id="userGrowthChart"></canvas>
        </div>

        <div class="chart-card">
          <div class="chart-header">
            <h3>Mission Status Distribution</h3>
          </div>
          <canvas id="missionStatusChart"></canvas>
        </div>
      </div>

      <!-- Activity Table -->
      <div class="activity-card">
        <div class="activity-header">
          <h3>Recent Activity</h3>
          <a href="#" class="view-all">View All</a>
        </div>
        <div class="activity-list">
          @for (activity of recentActivity(); track activity.id) {
            <div class="activity-item">
              <div class="activity-icon" [class]="activity.type">
                <svg width="16" height="16" viewBox="0 0 20 20" fill="currentColor">
                  @if (activity.type === 'user') {
                    <path d="M10 9a3 3 0 100-6 3 3 0 000 6zm-7 9a7 7 0 1114 0H3z"/>
                  } @else if (activity.type === 'mission') {
                    <path fill-rule="evenodd" d="M6 2a1 1 0 00-1 1v1H4a2 2 0 00-2 2v10a2 2 0 002 2h12a2 2 0 002-2V6a2 2 0 00-2-2h-1V3a1 1 0 10-2 0v1H7V3a1 1 0 00-1-1zm0 5a1 1 0 000 2h8a1 1 0 100-2H6z"/>
                  } @else {
                    <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"/>
                  }
                </svg>
              </div>
              <div class="activity-content">
                <p class="activity-text">{{ activity.text }}</p>
                <p class="activity-time">{{ activity.time }}</p>
              </div>
            </div>
          }
        </div>
      </div>
    </div>
  `,
  styles: [`
    .overview-page {
      max-width: 1400px;
    }

    .page-header {
      display: flex;
      justify-content: space-between;
      align-items: flex-start;
      margin-bottom: 32px;
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

    .btn-refresh {
      display: flex;
      align-items: center;
      gap: 8px;
      padding: 10px 20px;
      background: white;
      border: 1px solid #e2e8f0;
      border-radius: 8px;
      color: #4a5568;
      font-weight: 500;
      cursor: pointer;
      transition: all 0.2s;
    }

    .btn-refresh:hover {
      border-color: #667eea;
      color: #667eea;
    }

    .stats-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
      gap: 20px;
      margin-bottom: 32px;
    }

    .stat-card {
      background: white;
      border-radius: 12px;
      padding: 24px;
      display: flex;
      gap: 16px;
      border: 1px solid #e2e8f0;
      transition: all 0.2s;
    }

    .stat-card:hover {
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.08);
      transform: translateY(-2px);
    }

    .stat-icon {
      width: 48px;
      height: 48px;
      border-radius: 10px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }

    .stat-icon.blue {
      background: #ebf4ff;
      color: #3182ce;
    }

    .stat-icon.green {
      background: #e6fffa;
      color: #38a169;
    }

    .stat-icon.purple {
      background: #faf5ff;
      color: #805ad5;
    }

    .stat-icon.orange {
      background: #fffaf0;
      color: #dd6b20;
    }

    .stat-content {
      flex: 1;
    }

    .stat-label {
      margin: 0 0 4px 0;
      font-size: 13px;
      color: #718096;
      font-weight: 500;
    }

    .stat-value {
      margin: 0 0 8px 0;
      font-size: 28px;
      font-weight: 700;
      color: #1a202c;
    }

    .stat-change {
      margin: 0;
      font-size: 12px;
      font-weight: 500;
    }

    .stat-change.positive {
      color: #38a169;
    }

    .stat-change.negative {
      color: #e53e3e;
    }

    .stat-change.neutral {
      color: #718096;
    }

    .charts-row {
      display: grid;
      grid-template-columns: 2fr 1fr;
      gap: 20px;
      margin-bottom: 32px;
    }

    .chart-card {
      background: white;
      border-radius: 12px;
      padding: 24px;
      border: 1px solid #e2e8f0;
    }

    .chart-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }

    .chart-header h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
      color: #1a202c;
    }

    .chart-filter {
      padding: 6px 12px;
      border: 1px solid #e2e8f0;
      border-radius: 6px;
      font-size: 13px;
      color: #4a5568;
      background: white;
      cursor: pointer;
    }

    canvas {
      max-height: 300px;
    }

    .activity-card {
      background: white;
      border-radius: 12px;
      padding: 24px;
      border: 1px solid #e2e8f0;
    }

    .activity-header {
      display: flex;
      justify-content: space-between;
      align-items: center;
      margin-bottom: 20px;
    }

    .activity-header h3 {
      margin: 0;
      font-size: 16px;
      font-weight: 600;
      color: #1a202c;
    }

    .view-all {
      color: #667eea;
      font-size: 13px;
      font-weight: 500;
      text-decoration: none;
    }

    .view-all:hover {
      text-decoration: underline;
    }

    .activity-list {
      display: flex;
      flex-direction: column;
      gap: 16px;
    }

    .activity-item {
      display: flex;
      gap: 12px;
      padding: 12px;
      border-radius: 8px;
      transition: background 0.2s;
    }

    .activity-item:hover {
      background: #f7fafc;
    }

    .activity-icon {
      width: 36px;
      height: 36px;
      border-radius: 8px;
      display: flex;
      align-items: center;
      justify-content: center;
      flex-shrink: 0;
    }

    .activity-icon.user {
      background: #ebf4ff;
      color: #3182ce;
    }

    .activity-icon.mission {
      background: #e6fffa;
      color: #38a169;
    }

    .activity-icon.alert {
      background: #fff5f5;
      color: #e53e3e;
    }

    .activity-content {
      flex: 1;
    }

    .activity-text {
      margin: 0 0 4px 0;
      font-size: 14px;
      color: #2d3748;
    }

    .activity-time {
      margin: 0;
      font-size: 12px;
      color: #a0aec0;
    }

    @media (max-width: 1024px) {
      .charts-row {
        grid-template-columns: 1fr;
      }
    }

    @media (max-width: 768px) {
      .stats-grid {
        grid-template-columns: 1fr;
      }
    }
  `]
})
export class OverviewComponent implements OnInit, AfterViewInit {
  stats = signal({
    totalUsers: 0,
    activeMissions: 0,
    totalSkills: 0,
    partnerPlaces: 0
  });

  recentActivity = signal([
    { id: 1, type: 'user', text: 'New user registered: john@example.com', time: '2 minutes ago' },
    { id: 2, type: 'mission', text: 'Mission completed: Guitar Lessons', time: '15 minutes ago' },
    { id: 3, type: 'user', text: 'New user registered: sarah@example.com', time: '1 hour ago' },
    { id: 4, type: 'mission', text: 'New mission created: Web Development', time: '2 hours ago' },
    { id: 5, type: 'alert', text: 'Dispute reported for mission #1234', time: '3 hours ago' }
  ]);

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadStats();
  }

  ngAfterViewInit(): void {
    setTimeout(() => {
      this.initCharts();
    }, 100);
  }

  loadStats(): void {
    // Load real stats from API
    this.apiService.getAllUsers().subscribe({
      next: (users) => {
        this.stats.update(s => ({ ...s, totalUsers: users.length }));
      },
      error: () => {
        // Use demo data if API fails
        this.stats.set({
          totalUsers: 1247,
          activeMissions: 89,
          totalSkills: 456,
          partnerPlaces: 12
        });
      }
    });

    this.apiService.getAllPartnerPlaces().subscribe({
      next: (places) => {
        this.stats.update(s => ({ ...s, partnerPlaces: places.length }));
      }
    });
  }

  refreshData(): void {
    this.loadStats();
  }

  initCharts(): void {
    // User Growth Chart
    const userCtx = document.getElementById('userGrowthChart') as any;
    if (userCtx) {
      new Chart(userCtx, {
        type: 'line',
        data: {
          labels: ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'],
          datasets: [{
            label: 'New Users',
            data: [12, 19, 15, 25, 22, 30, 28],
            borderColor: '#667eea',
            backgroundColor: 'rgba(102, 126, 234, 0.1)',
            tension: 0.4,
            fill: true
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: true,
          plugins: {
            legend: {
              display: false
            }
          },
          scales: {
            y: {
              beginAtZero: true,
              grid: {
                color: '#f7fafc'
              }
            },
            x: {
              grid: {
                display: false
              }
            }
          }
        }
      });
    }

    // Mission Status Chart
    const missionCtx = document.getElementById('missionStatusChart') as any;
    if (missionCtx) {
      new Chart(missionCtx, {
        type: 'doughnut',
        data: {
          labels: ['Completed', 'Active', 'Pending', 'Cancelled'],
          datasets: [{
            data: [45, 25, 20, 10],
            backgroundColor: [
              '#38a169',
              '#3182ce',
              '#f6ad55',
              '#e53e3e'
            ],
            borderWidth: 0
          }]
        },
        options: {
          responsive: true,
          maintainAspectRatio: true,
          plugins: {
            legend: {
              position: 'bottom'
            }
          }
        }
      });
    }
  }
}
