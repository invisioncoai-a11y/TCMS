using System;
using System.ComponentModel.DataAnnotations;

namespace TrainingCourses.Api.DTOs
{
    // Auth
    public class LoginRequestDto
    {
        [Required]
        public string Username { get; set; } = string.Empty;

        [Required]
        public string Password { get; set; } = string.Empty;
    }

    public class LoginResponseDto
    {
        public string Token { get; set; } = string.Empty;
        public int AdminID { get; set; }
        public string Username { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public DateTime ExpiresAt { get; set; }
    }

    public class AdminDto
    {
        public int AdminID { get; set; }
        public string Username { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public int IsActive { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime? LastLogin { get; set; }
    }

    public class CreateAdminDto
    {
        [Required, MaxLength(50)]
        public string Username { get; set; } = string.Empty;

        [Required, MinLength(6)]
        public string Password { get; set; } = string.Empty;

        [Required, EmailAddress, MaxLength(100)]
        public string Email { get; set; } = string.Empty;

        [Required, MaxLength(100)]
        public string FullName { get; set; } = string.Empty;
    }

    public class ChangePasswordDto
    {
        [Required]
        public string CurrentPassword { get; set; } = string.Empty;

        [Required, MinLength(6)]
        public string NewPassword { get; set; } = string.Empty;
    }

    // Category
    public class CategoryDto
    {
        public int CategoryID { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateCategoryDto
    {
        [Required, MaxLength(100)]
        public string CategoryName { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Description { get; set; }
    }

    public class UpdateCategoryDto : CreateCategoryDto { }

    // Course
    public class CourseDto
    {
        public int CourseID { get; set; }
        public int CategoryID { get; set; }
        public string? CategoryName { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public string? LearningObjectives { get; set; }
        public string? Prerequisites { get; set; }
        public decimal Price { get; set; }
        public int Duration { get; set; }
        public string DeliveryMode { get; set; } = "Online";
        public int IsFeatured { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class CreateCourseDto
    {
        [Required]
        public int CategoryID { get; set; }

        [Required, MaxLength(150)]
        public string CourseName { get; set; } = string.Empty;

        public string? Description { get; set; }
        public string? LearningObjectives { get; set; }

        [MaxLength(500)]
        public string? Prerequisites { get; set; }

        [Range(0, 100000)]
        public decimal Price { get; set; }

        [Range(1, 1000)]
        public int Duration { get; set; }

        [Required]
        public string DeliveryMode { get; set; } = "Online";

        public int IsFeatured { get; set; } = 0;
    }

    public class UpdateCourseDto : CreateCourseDto { }

    public class CourseSearchFilterDto
    {
        public string? Search { get; set; }
        public int? CategoryID { get; set; }
        public decimal? MinPrice { get; set; }
        public decimal? MaxPrice { get; set; }
        public string? DeliveryMode { get; set; }
        public string? SortBy { get; set; }
    }

    // Trainer
    public class TrainerDto
    {
        public int TrainerID { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Specialization { get; set; } = string.Empty;
        public string? Qualifications { get; set; }
        public string? ProfileDetails { get; set; }
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateTrainerDto
    {
        [Required, MaxLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required, MaxLength(100)]
        public string Specialization { get; set; } = string.Empty;

        [MaxLength(500)]
        public string? Qualifications { get; set; }

        public string? ProfileDetails { get; set; }

        [Required, EmailAddress, MaxLength(100)]
        public string Email { get; set; } = string.Empty;

        [MaxLength(20)]
        public string? PhoneNumber { get; set; }
    }

    public class UpdateTrainerDto : CreateTrainerDto { }

    public class TrainerAssignedCourseDto
    {
        public int OfferingID { get; set; }
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public decimal Price { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string? ScheduleDetails { get; set; }
        public int MaxCapacity { get; set; }
        public int AvailableSeats { get; set; }
    }

    // Course Offering
    public class CourseOfferingDto
    {
        public int OfferingID { get; set; }
        public int CourseID { get; set; }
        public string? CourseName { get; set; }
        public decimal Price { get; set; }
        public int Duration { get; set; }
        public string? DeliveryMode { get; set; }
        public int CategoryID { get; set; }
        public string? CategoryName { get; set; }
        public int TrainerID { get; set; }
        public string? TrainerName { get; set; }
        public string? TrainerSpecialization { get; set; }
        public string? TrainerEmail { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string ScheduleDetails { get; set; } = string.Empty;
        public int MaxCapacity { get; set; }
        public int AvailableSeats { get; set; }
        public int EnrolledCount { get; set; }
        public string? SeatStatus { get; set; }
        public int IsUpcoming { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class CreateOfferingDto
    {
        [Required]
        public int CourseID { get; set; }

        [Required]
        public int TrainerID { get; set; }

        [Required]
        public DateTime StartDate { get; set; }

        [Required]
        public DateTime EndDate { get; set; }

        [Required, MaxLength(255)]
        public string ScheduleDetails { get; set; } = string.Empty;

        [Range(1, 1000)]
        public int MaxCapacity { get; set; }
    }

    public class UpdateOfferingDto : CreateOfferingDto { }

    // Trainee
    public class TraineeDto
    {
        public int TraineeID { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string EducationalBackground { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
    }

    public class CreateTraineeDto
    {
        [Required, MaxLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required, EmailAddress, MaxLength(100)]
        public string Email { get; set; } = string.Empty;

        [Required, MaxLength(20)]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required, MaxLength(255)]
        public string EducationalBackground { get; set; } = string.Empty;
    }

    public class UpdateTraineeDto : CreateTraineeDto { }

    // Registration
    public class RegistrationDto
    {
        public int RegistrationID { get; set; }
        public int TraineeID { get; set; }
        public string? TraineeName { get; set; }
        public string? TraineeEmail { get; set; }
        public string? TraineePhone { get; set; }
        public string? EducationalBackground { get; set; }
        public int OfferingID { get; set; }
        public int CourseID { get; set; }
        public string? CourseName { get; set; }
        public decimal Price { get; set; }
        public string? DeliveryMode { get; set; }
        public int TrainerID { get; set; }
        public string? TrainerName { get; set; }
        public DateTime StartDate { get; set; }
        public DateTime EndDate { get; set; }
        public string? ScheduleDetails { get; set; }
        public DateTime RegistrationDate { get; set; }
        public string Status { get; set; } = "Confirmed";
        public string? CancellationReason { get; set; }
        public DateTime? CancellationDate { get; set; }
        public int IsCancellable { get; set; }
        public DateTime CreatedAt { get; set; }
    }

    public class EnrollRequestDto
    {
        // Trainee details (either existing or to be created if not exists)
        [Required, MaxLength(100)]
        public string FullName { get; set; } = string.Empty;

        [Required, EmailAddress, MaxLength(100)]
        public string Email { get; set; } = string.Empty;

        [Required, MaxLength(20)]
        public string PhoneNumber { get; set; } = string.Empty;

        [Required, MaxLength(255)]
        public string EducationalBackground { get; set; } = string.Empty;

        [Required]
        public int OfferingID { get; set; }
    }

    public class CancelRegistrationDto
    {
        [Required]
        public int RegistrationID { get; set; }

        [Required, MaxLength(255)]
        public string Reason { get; set; } = string.Empty;
    }

    public class UpdateRegistrationStatusDto
    {
        [Required]
        public string Status { get; set; } = "Confirmed";
    }

    // Dashboard & Reports
    public class DashboardKpiDto
    {
        public int TotalCourses { get; set; }
        public int TotalOfferings { get; set; }
        public int TotalTrainers { get; set; }
        public int TotalTrainees { get; set; }
        public int TotalRegistrations { get; set; }
        public int ActiveOfferings { get; set; }
        public decimal TotalRevenue { get; set; }
    }

    public class CategoryChartDto
    {
        public int CategoryID { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public int RegistrationCount { get; set; }
        public int CourseCount { get; set; }
    }

    public class PopularCourseDto
    {
        public int CourseID { get; set; }
        public string CourseName { get; set; } = string.Empty;
        public string? CategoryName { get; set; }
        public decimal Price { get; set; }
        public int Duration { get; set; }
        public string? DeliveryMode { get; set; }
        public int TotalEnrollments { get; set; }
        public int TotalOfferings { get; set; }
    }
}
