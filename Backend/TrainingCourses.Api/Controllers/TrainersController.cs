using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrainingCourses.Api.DTOs;
using TrainingCourses.Api.Services;

namespace TrainingCourses.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class TrainersController : ControllerBase
    {
        private readonly ITrainerService _trainerService;

        public TrainersController(ITrainerService trainerService)
        {
            _trainerService = trainerService;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll()
        {
            var trainers = await _trainerService.GetAllTrainersAsync();
            return Ok(trainers);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetById(int id)
        {
            var trainer = await _trainerService.GetTrainerByIdAsync(id);
            if (trainer == null) return NotFound(new { message = $"Trainer with ID {id} not found." });
            return Ok(trainer);
        }

        [HttpGet("search")]
        [AllowAnonymous]
        public async Task<IActionResult> Search([FromQuery] string? search, [FromQuery] string? specialization)
        {
            var trainers = await _trainerService.SearchAndFilterTrainersAsync(search, specialization);
            return Ok(trainers);
        }

        [HttpGet("{id}/courses")]
        [AllowAnonymous]
        public async Task<IActionResult> GetAssignedCourses(int id)
        {
            var courses = await _trainerService.GetTrainerAssignedCoursesAsync(id);
            return Ok(courses);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Create([FromBody] CreateTrainerDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            int newId = await _trainerService.CreateTrainerAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = newId }, new { trainerID = newId, message = "Trainer created successfully." });
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateTrainerDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var existing = await _trainerService.GetTrainerByIdAsync(id);
            if (existing == null) return NotFound(new { message = $"Trainer with ID {id} not found." });

            await _trainerService.UpdateTrainerAsync(id, dto);
            return Ok(new { message = "Trainer updated successfully." });
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _trainerService.GetTrainerByIdAsync(id);
            if (existing == null) return NotFound(new { message = $"Trainer with ID {id} not found." });

            await _trainerService.DeleteTrainerAsync(id);
            return Ok(new { message = "Trainer deleted successfully." });
        }
    }
}
