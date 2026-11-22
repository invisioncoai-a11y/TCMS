import { Component, OnInit } from '@angular/core';
import { CommonModule } from '@angular/common';
import { FormsModule } from '@angular/forms';
import { RouterLink } from '@angular/router';
import { ApiService } from '../../services/api.service';
import { Trainer } from '../../models/models';

@Component({
  selector: 'app-trainers',
  standalone: true,
  imports: [CommonModule, FormsModule, RouterLink],
  templateUrl: './trainers.html',
  styleUrl: './trainers.css'
})
export class TrainersComponent implements OnInit {
  trainers: Trainer[] = [];
  searchTerm = '';
  loading = true;

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.onSearch();
  }

  onSearch(): void {
    this.loading = true;
    this.api.searchTrainers(this.searchTerm).subscribe({
      next: (data) => {
        this.trainers = data;
        this.loading = false;
      },
      error: () => (this.loading = false)
    });
  }
}
