import { Routes } from '@angular/router';
import { HomeComponent } from './pages/home/home';
import { CoursesComponent } from './pages/courses/courses';
import { CourseDetailsComponent } from './pages/course-details/course-details';
import { TrainersComponent } from './pages/trainers/trainers';
import { TrainerDetailsComponent } from './pages/trainer-details/trainer-details';
import { EnrollComponent } from './pages/enroll/enroll';
import { TraineeRegisterComponent } from './pages/trainee-register/trainee-register';
import { MyRegistrationsComponent } from './pages/my-registrations/my-registrations';
import { AdminLoginComponent } from './pages/admin-login/admin-login';
import { AdminDashboardComponent } from './pages/admin-dashboard/admin-dashboard';
import { AdminManageComponent } from './pages/admin-manage/admin-manage';
import { NotFoundComponent } from './pages/not-found/not-found';
import { authGuard } from './guards/auth.guard';

export const routes: Routes = [
  { path: '', component: HomeComponent, pathMatch: 'full' },
  { path: 'courses', component: CoursesComponent },
  { path: 'courses/:id', component: CourseDetailsComponent },
  { path: 'trainers', component: TrainersComponent },
  { path: 'trainers/:id', component: TrainerDetailsComponent },
  { path: 'register', component: EnrollComponent },
  { path: 'register/:offeringId', component: EnrollComponent },
  { path: 'trainee-register', component: TraineeRegisterComponent },
  { path: 'my-registrations', component: MyRegistrationsComponent },
  { path: 'admin/login', component: AdminLoginComponent },
  { path: 'admin/dashboard', component: AdminDashboardComponent, canActivate: [authGuard] },
  { path: 'admin/manage', component: AdminManageComponent, canActivate: [authGuard] },
  { path: '**', component: NotFoundComponent }
];
