using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrainingCourses.Api.DTOs;
using TrainingCourses.Api.Services;

namespace TrainingCourses.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TraineesController : ControllerBase
    {
        private readonly ITraineeService _traineeService;

        public TraineesController(ITraineeService traineeService)
        {
            _traineeService = traineeService;
        }

        [HttpGet]
        [Authorize]
        public async Task<IActionResult> GetAll()
        {
            var trainees = await _traineeService.GetAllTraineesAsync();
            return Ok(trainees);
        }

        [HttpGet("{id}")]
        [Authorize]
        public async Task<IActionResult> GetById(int id)
        {
            var trainee = await _traineeService.GetTraineeByIdAsync(id);
            if (trainee == null) return NotFound(new { message = $"Trainee with ID {id} not found." });
            return Ok(trainee);
        }

        [HttpGet("by-email")]
        [AllowAnonymous]
        public async Task<IActionResult> GetByEmail([FromQuery] string email)
        {
            if (string.IsNullOrWhiteSpace(email)) return BadRequest(new { message = "Email parameter is required." });
            var trainee = await _traineeService.GetTraineeByEmailAsync(email);
            if (trainee == null) return NotFound(new { message = $"Trainee with email {email} not found." });
            return Ok(trainee);
        }

        [HttpPost]
        [AllowAnonymous]
        public async Task<IActionResult> Create([FromBody] CreateTraineeDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var existing = await _traineeService.GetTraineeByEmailAsync(dto.Email);
            if (existing != null)
            {
                return Conflict(new { message = "A trainee with this email address already exists." });
            }

            int newId = await _traineeService.CreateTraineeAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = newId }, new { traineeID = newId, message = "Trainee registered." });
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateTraineeDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var existing = await _traineeService.GetTraineeByIdAsync(id);
            if (existing == null) return NotFound(new { message = $"Trainee with ID {id} not found." });

            await _traineeService.UpdateTraineeAsync(id, dto);
            return Ok(new { message = "Trainee profile updated." });
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _traineeService.GetTraineeByIdAsync(id);
            if (existing == null) return NotFound(new { message = $"Trainee with ID {id} not found." });

            await _traineeService.DeleteTraineeAsync(id);
            return Ok(new { message = "Trainee deleted." });
        }
    }
}
