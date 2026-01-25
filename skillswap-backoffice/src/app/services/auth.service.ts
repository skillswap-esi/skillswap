import { Injectable, signal } from '@angular/core';
import { Router } from '@angular/router';
import { ApiService, AdminLoginResponse } from './api.service';
import { firstValueFrom } from 'rxjs';

export interface AdminUser {
  email: string;
  token: string;
  role: string;
}

@Injectable({
  providedIn: 'root'
})
export class AuthService {
  private readonly TOKEN_KEY = 'admin_token';

  currentUser = signal<AdminUser | null>(null);
  isLoading = signal<boolean>(false);
  error = signal<string | null>(null);

  constructor(
    private router: Router,
    private apiService: ApiService
  ) {
    this.loadUser();
  }

  async login(email: string, password: string): Promise<boolean> {
    this.isLoading.set(true);
    this.error.set(null);

    try {
      // Call backend API for authentication
      const response: AdminLoginResponse = await firstValueFrom(
        this.apiService.adminLogin({ email, password })
      );

      const user: AdminUser = {
        email: response.email,
        token: response.token,
        role: response.role
      };

      localStorage.setItem(this.TOKEN_KEY, JSON.stringify(user));
      this.currentUser.set(user);
      this.isLoading.set(false);
      return true;
    } catch (err: any) {
      console.error('Login failed:', err);
      const errorMessage = err?.error?.error || 'Invalid credentials';
      this.error.set(errorMessage);
      this.isLoading.set(false);
      return false;
    }
  }

  logout(): void {
    localStorage.removeItem(this.TOKEN_KEY);
    this.currentUser.set(null);
    this.router.navigate(['/login']);
  }

  isAuthenticated(): boolean {
    return this.currentUser() !== null;
  }

  getToken(): string | null {
    const user = this.currentUser();
    return user?.token || null;
  }

  private loadUser(): void {
    try {
      const stored = localStorage.getItem(this.TOKEN_KEY);
      if (stored) {
        this.currentUser.set(JSON.parse(stored));
      }
    } catch (e) {
      // Ignore errors during initialization
    }
  }
}

