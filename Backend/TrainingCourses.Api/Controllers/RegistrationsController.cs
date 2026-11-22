using System;
using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrainingCourses.Api.DTOs;
using TrainingCourses.Api.Services;

namespace TrainingCourses.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class RegistrationsController : ControllerBase
    {
        private readonly IRegistrationService _registrationService;

        public RegistrationsController(IRegistrationService registrationService)
        {
            _registrationService = registrationService;
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetAll()
        {
            var registrations = await _registrationService.GetAllRegistrationsAsync();
            return Ok(registrations);
        }

        [HttpGet("{id}")]
        [Authorize]
        public async Task<IActionResult> GetById(int id)
        {
            var reg = await _registrationService.GetRegistrationByIdAsync(id);
            if (reg == null) return NotFound(new { message = $"Registration with ID {id} not found." });
            return Ok(reg);
        }

        [HttpGet("trainee/{traineeId}")]
        [Authorize]
        public async Task<IActionResult> GetByTrainee(int traineeId)
        {
            var registrations = await _registrationService.GetRegistrationsByTraineeAsync(traineeId);
            return Ok(registrations);
        }

        [HttpGet("my-registrations")]
        [AllowAnonymous]
        public async Task<IActionResult> GetMyRegistrations([FromQuery] string email)
        {
            if (string.IsNullOrWhiteSpace(email))
            {
                return BadRequest(new { message = "Email parameter is required to search registrations." });
            }

            var registrations = await _registrationService.GetRegistrationsByEmailAsync(email);
            return Ok(registrations);
        }

        [HttpPost("enroll")]
        [AllowAnonymous]
        public async Task<IActionResult> Enroll([FromBody] EnrollRequestDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                int regId = await _registrationService.EnrollTraineeAsync(dto);
                return Ok(new
                {
                    registrationID = regId,
                    message = "Successfully enrolled in course offering! Confirmation details recorded."
                });
            }
            catch (Exception ex)
            {
                // Inspect Oracle exception code
                if (ex.Message.Contains("ORA-20001"))
                {
                    return Conflict(new { message = "You are already registered for this course offering." });
                }
                if (ex.Message.Contains("ORA-20002"))
                {
                    return BadRequest(new { message = "Cannot register for a course offering that has already started." });
                }
                if (ex.Message.Contains("ORA-20003"))
                {
                    return BadRequest(new { message = "This course offering is fully booked. No seats available." });
                }
                return BadRequest(new { message = "Registration failed.", detail = ex.Message });
            }
        }

        [HttpPost("cancel")]
        [AllowAnonymous]
        public async Task<IActionResult> Cancel([FromBody] CancelRegistrationDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                await _registrationService.CancelRegistrationAsync(dto.RegistrationID, dto.Reason);
                return Ok(new { message = "Registration has been successfully cancelled and seat restored." });
            }
            catch (Exception ex)
            {
                if (ex.Message.Contains("ORA-20004"))
                {
                    return BadRequest(new { message = "Cannot cancel registration for a course offering that has already started." });
                }
                return BadRequest(new { message = "Cancellation failed.", detail = ex.Message });
            }
        }

        [HttpPut("{id}/status")]
        [Authorize]
        public async Task<IActionResult> UpdateStatus(int id, [FromBody] UpdateRegistrationStatusDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);

            try
            {
                await _registrationService.UpdateStatusAsync(id, dto.Status);
                return Ok(new { message = "Registration status updated." });
            }
            catch (Exception ex)
            {
                return BadRequest(new { message = "Status update failed.", detail = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> Delete(int id)
        {
            await _registrationService.DeleteRegistrationAsync(id);
            return Ok(new { message = "Registration deleted." });
        }
    }
}
