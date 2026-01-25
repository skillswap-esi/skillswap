import { Component, signal } from '@angular/core';
import { Router } from '@angular/router';
import { FormsModule } from '@angular/forms';
import { CommonModule } from '@angular/common';
import { AuthService } from '../../services/auth.service';

@Component({
  selector: 'app-login',
  imports: [CommonModule, FormsModule],
  template: `
    <div class="login-container">
      <div class="login-card">
        <div class="logo-section">
          <div class="logo-icon">
            <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
              <rect width="48" height="48" rx="12" fill="url(#gradient)"/>
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
          <h1>SkillSwap</h1>
          <p class="subtitle">Admin Backoffice</p>
        </div>

        @if (errorMessage()) {
          <div class="alert alert-error">
            <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M10 18a8 8 0 100-16 8 8 0 000 16zM8.707 7.293a1 1 0 00-1.414 1.414L8.586 10l-1.293 1.293a1 1 0 101.414 1.414L10 11.414l1.293 1.293a1 1 0 001.414-1.414L11.414 10l1.293-1.293a1 1 0 00-1.414-1.414L10 8.586 8.707 7.293z"/>
            </svg>
            {{ errorMessage() }}
          </div>
        }

        <form (ngSubmit)="onLogin()">
          <div class="form-group">
            <label for="email">
              <svg width="16" height="16" viewBox="0 0 20 20" fill="currentColor">
                <path d="M2.003 5.884L10 9.882l7.997-3.998A2 2 0 0016 4H4a2 2 0 00-1.997 1.884z"/>
                <path d="M18 8.118l-8 4-8-4V14a2 2 0 002 2h12a2 2 0 002-2V8.118z"/>
              </svg>
              Email Address
            </label>
            <input
              type="email"
              id="email"
              [(ngModel)]="email"
              name="email"
              placeholder="admin@skillswap.com"
              required
              autocomplete="email"
            />
          </div>

          <div class="form-group">
            <label for="password">
              <svg width="16" height="16" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M5 9V7a5 5 0 0110 0v2a2 2 0 012 2v5a2 2 0 01-2 2H5a2 2 0 01-2-2v-5a2 2 0 012-2zm8-2v2H7V7a3 3 0 016 0z"/>
              </svg>
              Password
            </label>
            <input
              type="password"
              id="password"
              [(ngModel)]="password"
              name="password"
              placeholder="Enter your password"
              required
              autocomplete="current-password"
            />
          </div>

          <button type="submit" class="btn-primary" [disabled]="loading()">
            @if (loading()) {
              <svg class="spinner" width="20" height="20" viewBox="0 0 20 20">
                <circle cx="10" cy="10" r="8" stroke="currentColor" stroke-width="2" fill="none" opacity="0.3"/>
                <path d="M10 2a8 8 0 018 8" stroke="currentColor" stroke-width="2" fill="none" stroke-linecap="round"/>
              </svg>
              Logging in...
            } @else {
              <svg width="20" height="20" viewBox="0 0 20 20" fill="currentColor">
                <path fill-rule="evenodd" d="M3 3a1 1 0 011 1v12a1 1 0 11-2 0V4a1 1 0 011-1zm7.707 3.293a1 1 0 010 1.414L9.414 9H17a1 1 0 110 2H9.414l1.293 1.293a1 1 0 01-1.414 1.414l-3-3a1 1 0 010-1.414l3-3a1 1 0 011.414 0z"/>
              </svg>
              Sign In
            }
          </button>
        </form>

        <div class="demo-credentials">
          <div class="demo-header">
            <svg width="16" height="16" viewBox="0 0 20 20" fill="currentColor">
              <path fill-rule="evenodd" d="M18 10a8 8 0 11-16 0 8 8 0 0116 0zm-7-4a1 1 0 11-2 0 1 1 0 012 0zM9 9a1 1 0 000 2v3a1 1 0 001 1h1a1 1 0 100-2v-3a1 1 0 00-1-1H9z"/>
            </svg>
            Demo Credentials
          </div>
          <div class="demo-content">
            <div class="demo-item">
              <span class="demo-label">Email:</span>
              <code>admin@skillswap.com</code>
            </div>
            <div class="demo-item">
              <span class="demo-label">Password:</span>
              <code>Admin123!</code>
            </div>
          </div>
        </div>
      </div>

      <div class="footer">
        <p>© 2026 SkillSwap. All rights reserved.</p>
      </div>
    </div>
  `,
  styles: [`
    .login-container {
      min-height: 100vh;
      display: flex;
      flex-direction: column;
      align-items: center;
      justify-content: center;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      padding: 20px;
      position: relative;
    }

    .login-container::before {
      content: '';
      position: absolute;
      top: 0;
      left: 0;
      right: 0;
      bottom: 0;
      background: 
        radial-gradient(circle at 20% 50%, rgba(255, 255, 255, 0.1) 0%, transparent 50%),
        radial-gradient(circle at 80% 80%, rgba(255, 255, 255, 0.1) 0%, transparent 50%);
      pointer-events: none;
    }

    .login-card {
      background: white;
      padding: 48px 40px;
      border-radius: 20px;
      box-shadow: 0 20px 60px rgba(0, 0, 0, 0.3);
      width: 100%;
      max-width: 440px;
      position: relative;
      z-index: 1;
    }

    .logo-section {
      text-align: center;
      margin-bottom: 40px;
    }

    .logo-icon {
      display: inline-block;
      margin-bottom: 16px;
      animation: float 3s ease-in-out infinite;
    }

    @keyframes float {
      0%, 100% { transform: translateY(0px); }
      50% { transform: translateY(-10px); }
    }

    h1 {
      margin: 0 0 8px 0;
      color: #1a202c;
      font-size: 32px;
      font-weight: 700;
      letter-spacing: -0.5px;
    }

    .subtitle {
      margin: 0;
      color: #718096;
      font-size: 16px;
      font-weight: 500;
    }

    .alert {
      display: flex;
      align-items: center;
      gap: 12px;
      padding: 14px 16px;
      border-radius: 12px;
      margin-bottom: 24px;
      font-size: 14px;
      font-weight: 500;
    }

    .alert-error {
      background: #fee;
      color: #c53030;
      border: 1px solid #fc8181;
    }

    .form-group {
      margin-bottom: 24px;
    }

    label {
      display: flex;
      align-items: center;
      gap: 8px;
      margin-bottom: 10px;
      color: #2d3748;
      font-weight: 600;
      font-size: 14px;
    }

    label svg {
      color: #667eea;
    }

    input {
      width: 100%;
      padding: 14px 16px;
      border: 2px solid #e2e8f0;
      border-radius: 12px;
      font-size: 15px;
      transition: all 0.3s ease;
      background: #f7fafc;
    }

    input:focus {
      outline: none;
      border-color: #667eea;
      background: white;
      box-shadow: 0 0 0 3px rgba(102, 126, 234, 0.1);
    }

    input::placeholder {
      color: #a0aec0;
    }

    .btn-primary {
      width: 100%;
      padding: 14px 24px;
      background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
      color: white;
      border: none;
      border-radius: 12px;
      font-size: 16px;
      font-weight: 600;
      cursor: pointer;
      transition: all 0.3s ease;
      display: flex;
      align-items: center;
      justify-content: center;
      gap: 8px;
      box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);
    }

    .btn-primary:hover:not(:disabled) {
      transform: translateY(-2px);
      box-shadow: 0 6px 20px rgba(102, 126, 234, 0.5);
    }

    .btn-primary:active:not(:disabled) {
      transform: translateY(0);
    }

    .btn-primary:disabled {
      opacity: 0.7;
      cursor: not-allowed;
      transform: none;
    }

    .spinner {
      animation: spin 1s linear infinite;
    }

    @keyframes spin {
      from { transform: rotate(0deg); }
      to { transform: rotate(360deg); }
    }

    .demo-credentials {
      margin-top: 32px;
      padding: 20px;
      background: linear-gradient(135deg, #f7fafc 0%, #edf2f7 100%);
      border-radius: 12px;
      border: 1px solid #e2e8f0;
    }

    .demo-header {
      display: flex;
      align-items: center;
      gap: 8px;
      font-weight: 600;
      color: #2d3748;
      margin-bottom: 12px;
      font-size: 14px;
    }

    .demo-header svg {
      color: #667eea;
    }

    .demo-content {
      display: flex;
      flex-direction: column;
      gap: 8px;
    }

    .demo-item {
      display: flex;
      align-items: center;
      gap: 8px;
      font-size: 13px;
    }

    .demo-label {
      color: #718096;
      font-weight: 500;
      min-width: 80px;
    }

    code {
      background: white;
      padding: 6px 12px;
      border-radius: 6px;
      font-family: 'Monaco', 'Courier New', monospace;
      font-size: 13px;
      color: #667eea;
      border: 1px solid #e2e8f0;
      flex: 1;
    }

    .footer {
      position: absolute;
      bottom: 20px;
      color: white;
      font-size: 13px;
      opacity: 0.9;
      z-index: 1;
    }

    @media (max-width: 480px) {
      .login-card {
        padding: 32px 24px;
      }

      h1 {
        font-size: 28px;
      }
    }
  `]
})
export class LoginComponent {
  email = '';
  password = '';
  loading = signal(false);
  errorMessage = signal('');

  constructor(
    private authService: AuthService,
    private router: Router
  ) { }

  async onLogin(): Promise<void> {
    this.loading.set(true);
    this.errorMessage.set('');

    try {
      const success = await this.authService.login(this.email, this.password);

      if (success) {
        this.router.navigate(['/dashboard']);
      } else {
        this.errorMessage.set(this.authService.error() || 'Invalid email or password. Please try again.');
      }
    } catch (error) {
      console.error('Login error:', error);
      this.errorMessage.set('Login failed. Please check your connection and try again.');
    } finally {
      this.loading.set(false);
    }
  }
}

