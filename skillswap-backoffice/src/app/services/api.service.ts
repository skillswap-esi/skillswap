import { Injectable } from '@angular/core';
import { HttpClient, HttpHeaders } from '@angular/common/http';
import { Observable } from 'rxjs';

export interface User {
  userId: string;
  email: string;
  fullName: string;
  phoneNumber: string;
  creditsBalance: number;
  helperScore: number;
  roles: string[];
  phoneVerified: boolean;
  createdAt: string;
  updatedAt: string;
}

export interface PartnerPlace {
  id?: string;
  name: string;
  address: string;
  city: string;
  latitude: number;
  longitude: number;
  type: string;
  active: boolean;
  phoneNumber?: string;
  description?: string;
}

export interface AdminLoginRequest {
  email: string;
  password: string;
}

export interface AdminLoginResponse {
  token: string;
  email: string;
  role: string;
}

@Injectable({
  providedIn: 'root'
})
export class ApiService {
  private readonly API_URL = 'http://localhost:8080/api';

  constructor(private http: HttpClient) { }

  private getHeaders(): HttpHeaders {
    return new HttpHeaders({
      'Content-Type': 'application/json'
    });
  }

  // Admin Authentication
  adminLogin(request: AdminLoginRequest): Observable<AdminLoginResponse> {
    return this.http.post<AdminLoginResponse>(`${this.API_URL}/admin/login`, request, {
      headers: this.getHeaders()
    });
  }

  // Users - Uses admin endpoint for backoffice
  getAllUsers(): Observable<User[]> {
    return this.http.get<User[]>(`${this.API_URL}/admin/users`, {
      headers: this.getHeaders()
    });
  }

  getUserCount(): Observable<{ count: number }> {
    return this.http.get<{ count: number }>(`${this.API_URL}/admin/users/count`, {
      headers: this.getHeaders()
    });
  }

  // Partner Places - Uses /all to get all places (including inactive) for backoffice
  getAllPartnerPlaces(): Observable<PartnerPlace[]> {
    return this.http.get<PartnerPlace[]>(`${this.API_URL}/missions/partner-places/all`, {
      headers: this.getHeaders()
    });
  }

  createPartnerPlace(place: PartnerPlace): Observable<PartnerPlace> {
    return this.http.post<PartnerPlace>(`${this.API_URL}/missions/partner-places`, place, {
      headers: this.getHeaders()
    });
  }

  updatePartnerPlace(id: string, place: PartnerPlace): Observable<PartnerPlace> {
    return this.http.put<PartnerPlace>(`${this.API_URL}/missions/partner-places/${id}`, place, {
      headers: this.getHeaders()
    });
  }

  deletePartnerPlace(id: string): Observable<void> {
    return this.http.delete<void>(`${this.API_URL}/missions/partner-places/${id}`, {
      headers: this.getHeaders()
    });
  }
}
