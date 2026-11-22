using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrainingCourses.Api.DTOs;
using TrainingCourses.Api.Services;

namespace TrainingCourses.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CourseOfferingsController : ControllerBase
    {
        private readonly IOfferingService _offeringService;

        public CourseOfferingsController(IOfferingService offeringService)
        {
            _offeringService = offeringService;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll()
        {
            var offerings = await _offeringService.GetAllOfferingsAsync();
            return Ok(offerings);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetById(int id)
        {
            var offering = await _offeringService.GetOfferingByIdAsync(id);
            if (offering == null) return NotFound(new { message = $"Course offering with ID {id} not found." });
            return Ok(offering);
        }

        [HttpGet("course/{courseId}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetByCourse(int courseId)
        {
            var offerings = await _offeringService.GetOfferingsByCourseAsync(courseId);
            return Ok(offerings);
        }

        [HttpGet("upcoming")]
        [AllowAnonymous]
        public async Task<IActionResult> GetUpcoming()
        {
            var offerings = await _offeringService.GetUpcomingOfferingsAsync();
            return Ok(offerings);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Create([FromBody] CreateOfferingDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            if (dto.EndDate <= dto.StartDate)
            {
                return BadRequest(new { message = "EndDate must be strictly after StartDate." });
            }

            int newId = await _offeringService.CreateOfferingAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = newId }, new { offeringID = newId, message = "Offering created successfully." });
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateOfferingDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var existing = await _offeringService.GetOfferingByIdAsync(id);
            if (existing == null) return NotFound(new { message = $"Offering with ID {id} not found." });

            try
            {
                await _offeringService.UpdateOfferingAsync(id, dto);
                return Ok(new { message = "Offering updated successfully." });
            }
            catch (System.Exception ex)
            {
                return BadRequest(new { message = ex.Message });
            }
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _offeringService.GetOfferingByIdAsync(id);
            if (existing == null) return NotFound(new { message = $"Offering with ID {id} not found." });

            await _offeringService.DeleteOfferingAsync(id);
            return Ok(new { message = "Offering deleted successfully." });
        }
    }
}
