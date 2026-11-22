import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { ActivatedRoute, RouterLink } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { CourseOffering, EnrollRequest } from '../../models/models';

@Component({
  selector: 'app-enroll',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './enroll.html',
  styleUrl: './enroll.css'
})
export class EnrollComponent implements OnInit {
  offeringId: number | null = null;
  offering: CourseOffering | null = null;
  upcomingOfferings: CourseOffering[] = [];

  form: EnrollRequest = {
    fullName: '',
    email: '',
    phoneNumber: '',
    educationalBackground: '',
    offeringID: 0
  };

  submitting = false;
  successMessage = '';
  errorMessage = '';
  registrationId: number | null = null;

  constructor(private route: ActivatedRoute, private api: ApiService) {}

  ngOnInit(): void {
    this.route.paramMap.subscribe((params) => {
      const id = params.get('offeringId');
      if (id) {
        this.offeringId = Number(id);
        this.form.offeringID = this.offeringId;
        this.loadSelectedOffering(this.offeringId);
      } else {
        this.loadUpcomingOfferings();
      }
    });
  }

  loadSelectedOffering(id: number): void {
    this.api.getOffering(id).subscribe({
      next: (off) => (this.offering = off),
      error: () => (this.errorMessage = 'Could not load selected course offering.')
    });
  }

  loadUpcomingOfferings(): void {
    this.api.getUpcomingOfferings().subscribe({
      next: (offs) => {
        this.upcomingOfferings = offs;
        if (offs.length > 0 && !this.form.offeringID) {
          this.form.offeringID = offs[0].offeringID;
          this.offering = offs[0];
        }
      }
    });
  }

  onOfferingChange(): void {
    const selected = this.upcomingOfferings.find((o) => o.offeringID === Number(this.form.offeringID));
    if (selected) {
      this.offering = selected;
    }
  }

  onSubmit(): void {
    if (!this.form.fullName || !this.form.email || !this.form.phoneNumber || !this.form.educationalBackground || !this.form.offeringID) {
      this.errorMessage = 'Please complete all required fields.';
      return;
    }

    this.submitting = true;
    this.errorMessage = '';
    this.successMessage = '';

    this.api.enroll(this.form).subscribe({
      next: (res) => {
        this.submitting = false;
        this.registrationId = res.registrationID;
        this.successMessage = res.message || 'Enrollment confirmed!';
      },
      error: (err) => {
        this.submitting = false;
        this.errorMessage = err.error?.message || 'Enrollment failed. Please verify remaining seats or try another offering.';
      }
    });
  }
}
