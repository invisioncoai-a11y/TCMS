import { Component, OnInit, AfterViewInit, ElementRef, ViewChild } from '@angular/core';
import { CommonModule } from '@angular/common';
import { RouterLink } from '@angular/router';
import { Chart, registerables } from 'chart.js';
import { ApiService } from '../../services/api.service';
import { DashboardKpis, CategoryChart, Registration } from '../../models/models';

Chart.register(...registerables);

@Component({
  selector: 'app-admin-dashboard',
  standalone: true,
  imports: [CommonModule, RouterLink],
  templateUrl: './admin-dashboard.html',
  styleUrl: './admin-dashboard.css'
})
export class AdminDashboardComponent implements OnInit, AfterViewInit {
  @ViewChild('categoryCanvas') categoryCanvas!: ElementRef<HTMLCanvasElement>;

  kpis: DashboardKpis | null = null;
  categoryData: CategoryChart[] = [];
  recentRegistrations: Registration[] = [];
  loading = true;
  chart: Chart | null = null;

  constructor(private api: ApiService) {}

  ngOnInit(): void {
    this.loadKpis();
    this.loadRecentRegistrations();
  }

  ngAfterViewInit(): void {
    this.loadCategoryChart();
  }

  loadKpis(): void {
    this.api.getDashboardKpis().subscribe({
      next: (k) => {
        this.kpis = k;
        this.loading = false;
      },
      error: () => (this.loading = false)
    });
  }

  loadCategoryChart(): void {
    this.api.getCategoryChart().subscribe({
      next: (cats) => {
        this.categoryData = cats;
        this.renderChart(cats);
      }
    });
  }

  renderChart(cats: CategoryChart[]): void {
    if (!this.categoryCanvas) return;
    if (this.chart) {
      this.chart.destroy();
    }

    const labels = cats.map((c) => c.categoryName);
    const data = cats.map((c) => c.registrationCount);

    this.chart = new Chart(this.categoryCanvas.nativeElement, {
      type: 'bar',
      data: {
        labels: labels,
        datasets: [
          {
            label: 'Confirmed & Pending Registrations',
            data: data,
            backgroundColor: [
              'rgba(37, 99, 235, 0.85)',
              'rgba(16, 185, 129, 0.85)',
              'rgba(245, 158, 11, 0.85)',
              'rgba(139, 92, 246, 0.85)',
              'rgba(239, 68, 68, 0.85)'
            ],
            borderColor: [
              '#2563eb',
              '#10b981',
              '#f59e0b',
              '#8b5cf6',
              '#ef4444'
            ],
            borderWidth: 1.5,
            borderRadius: 6
          }
        ]
      },
      options: {
        responsive: true,
        maintainAspectRatio: false,
        plugins: {
          legend: {
            display: false
          },
          tooltip: {
            callbacks: {
              label: (item) => ` ${item.raw} Registrations`
            }
          }
        },
        scales: {
          y: {
            beginAtZero: true,
            ticks: {
              stepSize: 1
            },
            grid: {
              color: '#f1f5f9'
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

  loadRecentRegistrations(): void {
    this.api.getRegistrations().subscribe({
      next: (regs) => (this.recentRegistrations = regs.slice(0, 6))
    });
  }
}
