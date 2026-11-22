import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { Registration } from '../../models/models';

@Component({
  selector: 'app-my-registrations',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './my-registrations.html',
  styleUrl: './my-registrations.css'
})
export class MyRegistrationsComponent implements OnInit {
  email = '';
  registrations: Registration[] = [];
  loading = false;
  searched = false;
  successMessage = '';
  errorMessage = '';

  // Cancel modal state
  selectedRegForCancel: Registration | null = null;
  cancelReason = '';
  cancelling = false;

  constructor(private api: ApiService, private route: ActivatedRoute) {}

  ngOnInit(): void {
    this.route.queryParams.subscribe((params) => {
      if (params['email']) {
        this.email = params['email'];
        this.onSearch();
      } else {
        // Pre-fill with sample student for instant demonstration
        this.email = 'alice.walker@example.com';
        this.onSearch();
      }
    });
  }

  onSearch(): void {
    if (!this.email || !this.email.trim()) {
      return;
    }

    this.loading = true;
    this.searched = true;
    this.successMessage = '';
    this.errorMessage = '';

    this.api.getMyRegistrations(this.email.trim()).subscribe({
      next: (data) => {
        this.registrations = data;
        this.loading = false;
      },
      error: (err) => {
        this.loading = false;
        this.errorMessage = 'Could not retrieve registrations for this email address.';
      }
    });
  }

  openCancelModal(reg: Registration): void {
    this.selectedRegForCancel = reg;
    this.cancelReason = '';
    this.errorMessage = '';
  }

  closeCancelModal(): void {
    this.selectedRegForCancel = null;
  }

  confirmCancel(): void {
    if (!this.selectedRegForCancel) return;
    if (!this.cancelReason.trim()) {
      this.errorMessage = 'Please provide a reason for cancellation.';
      return;
    }

    this.cancelling = true;
    this.errorMessage = '';

    this.api
      .cancelRegistration({
        registrationID: this.selectedRegForCancel.registrationID,
        reason: this.cancelReason.trim()
      })
      .subscribe({
        next: (res) => {
          this.cancelling = false;
          this.successMessage = res.message || 'Registration successfully cancelled and seat restored!';
          this.closeCancelModal();
          this.onSearch();
        },
        error: (err) => {
          this.cancelling = false;
          this.errorMessage = err.error?.message || 'Cancellation failed.';
        }
      });
  }
}
