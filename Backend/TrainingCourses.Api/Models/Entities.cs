using System;

namespace TrainingCourses.Api.Models
{
    public class Admin
    {
        public int AdminID { get; set; }
        public string Username { get; set; } = string.Empty;
        public string PasswordHash { get; set; } = string.Empty;
        public string? PasswordSalt { get; set; }
        public string Email { get; set; } = string.Empty;
        public string FullName { get; set; } = string.Empty;
        public int IsActive { get; set; } = 1;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
        public DateTime? LastLogin { get; set; }
    }

    public class Category
    {
        public int CategoryID { get; set; }
        public string CategoryName { get; set; } = string.Empty;
        public string? Description { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class Trainer
    {
        public int TrainerID { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Specialization { get; set; } = string.Empty;
        public string? Qualifications { get; set; }
        public string? ProfileDetails { get; set; }
        public string Email { get; set; } = string.Empty;
        public string? PhoneNumber { get; set; }
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class Course
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

    public class CourseOffering
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

    public class Trainee
    {
        public int TraineeID { get; set; }
        public string FullName { get; set; } = string.Empty;
        public string Email { get; set; } = string.Empty;
        public string PhoneNumber { get; set; } = string.Empty;
        public string EducationalBackground { get; set; } = string.Empty;
        public DateTime CreatedAt { get; set; }
        public DateTime UpdatedAt { get; set; }
    }

    public class Registration
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
}
