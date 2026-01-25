import { Component, OnInit, signal } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ApiService, PartnerPlace } from '../../services/api.service';

@Component({
  selector: 'app-partner-places',
  imports: [CommonModule, FormsModule],
  template: `
    <div class="partner-places-page">
      <div class="page-header">
        <h1>Partner Places Management</h1>
        <button (click)="showAddForm()" class="btn-primary">
          ➕ Add Partner Place
        </button>
      </div>

      @if (showForm()) {
        <div class="form-card">
          <h3>{{ editingPlace() ? 'Edit' : 'Add' }} Partner Place</h3>
          
          <form (ngSubmit)="savePlace()">
            <div class="form-row">
              <div class="form-group">
                <label>Name *</label>
                <input
                  type="text"
                  [(ngModel)]="formData.name"
                  name="name"
                  placeholder="Café Central"
                  required
                />
              </div>

              <div class="form-group">
                <label>Type *</label>
                <select [(ngModel)]="formData.type" name="type" required>
                  <option value="CAFE">Café</option>
                  <option value="COWORKING">Coworking Space</option>
                  <option value="LIBRARY">Library</option>
                  <option value="PARK">Park</option>
                  <option value="OTHER">Other</option>
                </select>
              </div>
            </div>

            <div class="form-group">
              <label>Address *</label>
              <input
                type="text"
                [(ngModel)]="formData.address"
                name="address"
                placeholder="Boulevard Mohammed V"
                required
              />
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>City *</label>
                <input
                  type="text"
                  [(ngModel)]="formData.city"
                  name="city"
                  placeholder="Casablanca"
                  required
                />
              </div>

              <div class="form-group">
                <label>Phone Number</label>
                <input
                  type="text"
                  [(ngModel)]="formData.phoneNumber"
                  name="phoneNumber"
                  placeholder="+212 522 123456"
                />
              </div>
            </div>

            <div class="form-row">
              <div class="form-group">
                <label>Latitude *</label>
                <input
                  type="number"
                  step="0.000001"
                  [(ngModel)]="formData.latitude"
                  name="latitude"
                  placeholder="33.5731"
                  required
                />
              </div>

              <div class="form-group">
                <label>Longitude *</label>
                <input
                  type="number"
                  step="0.000001"
                  [(ngModel)]="formData.longitude"
                  name="longitude"
                  placeholder="-7.5898"
                  required
                />
              </div>
            </div>

            <div class="form-group">
              <label>Description</label>
              <textarea
                [(ngModel)]="formData.description"
                name="description"
                rows="3"
                placeholder="Popular café in city center with WiFi"
              ></textarea>
            </div>

            <div class="form-group">
              <label>
                <input
                  type="checkbox"
                  [(ngModel)]="formData.active"
                  name="active"
                />
                Active
              </label>
            </div>

            <div class="form-actions">
              <button type="button" (click)="cancelForm()" class="btn-secondary">
                Cancel
              </button>
              <button type="submit" class="btn-primary" [disabled]="saving()">
                {{ saving() ? 'Saving...' : 'Save' }}
              </button>
            </div>
          </form>
        </div>
      }

      @if (error()) {
        <div class="error-message">{{ error() }}</div>
      }

      @if (loading()) {
        <div class="loading">Loading partner places...</div>
      }

      @if (!loading() && places().length > 0) {
        <div class="places-grid">
          @for (place of places(); track place.id) {
            <div class="place-card">
              <div class="place-header">
                <h3>{{ place.name }}</h3>
                <span class="badge" [class.badge-active]="place.active">
                  {{ place.active ? 'Active' : 'Inactive' }}
                </span>
              </div>
              
              <div class="place-info">
                <p><strong>Type:</strong> {{ place.type }}</p>
                <p><strong>Address:</strong> {{ place.address }}</p>
                <p><strong>City:</strong> {{ place.city }}</p>
                <p><strong>Coordinates:</strong> {{ place.latitude }}, {{ place.longitude }}</p>
                @if (place.phoneNumber) {
                  <p><strong>Phone:</strong> {{ place.phoneNumber }}</p>
                }
                @if (place.description) {
                  <p><strong>Description:</strong> {{ place.description }}</p>
                }
              </div>

              <div class="place-actions">
                <button (click)="editPlace(place)" class="btn-edit">
                  ✏️ Edit
                </button>
                <button (click)="deletePlace(place.id!)" class="btn-delete">
                  🗑️ Delete
                </button>
              </div>
            </div>
          }
        </div>
      }

      @if (!loading() && places().length === 0 && !error()) {
        <div class="empty-state">
          <p>No partner places found. Add your first one!</p>
        </div>
      }
    </div>
  `,
  styles: [`
    .partner-places-page {
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

    .btn-primary {
      padding: 10px 20px;
      background: #667eea;
      color: white;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
    }

    .btn-primary:hover:not(:disabled) {
      background: #5568d3;
    }

    .btn-primary:disabled {
      opacity: 0.6;
      cursor: not-allowed;
    }

    .btn-secondary {
      padding: 10px 20px;
      background: #f5f5f5;
      color: #666;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
    }

    .btn-secondary:hover {
      background: #e0e0e0;
    }

    .form-card {
      background: #f9f9f9;
      padding: 24px;
      border-radius: 8px;
      margin-bottom: 24px;
    }

    .form-card h3 {
      margin: 0 0 20px 0;
      color: #333;
    }

    .form-row {
      display: grid;
      grid-template-columns: 1fr 1fr;
      gap: 16px;
    }

    .form-group {
      margin-bottom: 16px;
    }

    .form-group label {
      display: block;
      margin-bottom: 8px;
      color: #333;
      font-weight: 500;
    }

    .form-group input[type="text"],
    .form-group input[type="number"],
    .form-group select,
    .form-group textarea {
      width: 100%;
      padding: 10px;
      border: 1px solid #ddd;
      border-radius: 6px;
      font-size: 14px;
      box-sizing: border-box;
    }

    .form-group input[type="checkbox"] {
      margin-right: 8px;
    }

    .form-actions {
      display: flex;
      gap: 12px;
      justify-content: flex-end;
      margin-top: 20px;
    }

    .places-grid {
      display: grid;
      grid-template-columns: repeat(auto-fill, minmax(350px, 1fr));
      gap: 20px;
    }

    .place-card {
      border: 1px solid #ddd;
      border-radius: 8px;
      padding: 20px;
      background: white;
      transition: box-shadow 0.3s;
    }

    .place-card:hover {
      box-shadow: 0 4px 12px rgba(0, 0, 0, 0.1);
    }

    .place-header {
      display: flex;
      justify-content: space-between;
      align-items: start;
      margin-bottom: 16px;
    }

    .place-header h3 {
      margin: 0;
      color: #333;
    }

    .badge {
      padding: 4px 12px;
      border-radius: 12px;
      font-size: 12px;
      font-weight: 600;
      background: #ffebee;
      color: #c62828;
    }

    .badge-active {
      background: #e8f5e9;
      color: #2e7d32;
    }

    .place-info {
      margin-bottom: 16px;
    }

    .place-info p {
      margin: 8px 0;
      color: #666;
      font-size: 14px;
    }

    .place-actions {
      display: flex;
      gap: 8px;
    }

    .btn-edit, .btn-delete {
      flex: 1;
      padding: 8px;
      border: none;
      border-radius: 6px;
      cursor: pointer;
      font-size: 14px;
    }

    .btn-edit {
      background: #e3f2fd;
      color: #1976d2;
    }

    .btn-edit:hover {
      background: #bbdefb;
    }

    .btn-delete {
      background: #ffebee;
      color: #c62828;
    }

    .btn-delete:hover {
      background: #ffcdd2;
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
export class PartnerPlacesComponent implements OnInit {
  places = signal<PartnerPlace[]>([]);
  loading = signal(false);
  saving = signal(false);
  error = signal('');
  showForm = signal(false);
  editingPlace = signal<PartnerPlace | null>(null);

  formData: PartnerPlace = this.getEmptyForm();

  constructor(private apiService: ApiService) {}

  ngOnInit(): void {
    this.loadPlaces();
  }

  loadPlaces(): void {
    this.loading.set(true);
    this.error.set('');

    this.apiService.getAllPartnerPlaces().subscribe({
      next: (data) => {
        this.places.set(data);
        this.loading.set(false);
      },
      error: (err) => {
        this.error.set('Failed to load partner places. Make sure the backend is running.');
        this.loading.set(false);
        console.error('Error loading places:', err);
      }
    });
  }

  showAddForm(): void {
    this.formData = this.getEmptyForm();
    this.editingPlace.set(null);
    this.showForm.set(true);
  }

  editPlace(place: PartnerPlace): void {
    this.formData = { ...place };
    this.editingPlace.set(place);
    this.showForm.set(true);
  }

  cancelForm(): void {
    this.showForm.set(false);
    this.editingPlace.set(null);
    this.formData = this.getEmptyForm();
  }

  savePlace(): void {
    this.saving.set(true);
    this.error.set('');

    const editing = this.editingPlace();
    const request = editing
      ? this.apiService.updatePartnerPlace(editing.id!, this.formData)
      : this.apiService.createPartnerPlace(this.formData);

    request.subscribe({
      next: () => {
        this.saving.set(false);
        this.cancelForm();
        this.loadPlaces();
      },
      error: (err) => {
        this.error.set('Failed to save partner place. Check the console for details.');
        this.saving.set(false);
        console.error('Error saving place:', err);
      }
    });
  }

  deletePlace(id: string): void {
    if (!confirm('Are you sure you want to delete this partner place?')) {
      return;
    }

    this.apiService.deletePartnerPlace(id).subscribe({
      next: () => {
        this.loadPlaces();
      },
      error: (err) => {
        this.error.set('Failed to delete partner place.');
        console.error('Error deleting place:', err);
      }
    });
  }

  private getEmptyForm(): PartnerPlace {
    return {
      name: '',
      address: '',
      city: '',
      latitude: 0,
      longitude: 0,
      type: 'CAFE',
      active: true,
      phoneNumber: '',
      description: ''
    };
  }
}
