using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrainingCourses.Api.DTOs;
using TrainingCourses.Api.Services;

namespace TrainingCourses.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class CoursesController : ControllerBase
    {
        private readonly ICourseService _courseService;

        public CoursesController(ICourseService courseService)
        {
            _courseService = courseService;
        }

        [HttpGet]
        [AllowAnonymous]
        public async Task<IActionResult> GetAll()
        {
            var courses = await _courseService.GetAllCoursesAsync();
            return Ok(courses);
        }

        [HttpGet("{id}")]
        [AllowAnonymous]
        public async Task<IActionResult> GetById(int id)
        {
            var course = await _courseService.GetCourseByIdAsync(id);
            if (course == null) return NotFound(new { message = $"Course with ID {id} not found." });
            return Ok(course);
        }

        [HttpGet("featured")]
        [AllowAnonymous]
        public async Task<IActionResult> GetFeatured()
        {
            var courses = await _courseService.GetFeaturedCoursesAsync();
            return Ok(courses);
        }

        [HttpGet("search")]
        [AllowAnonymous]
        public async Task<IActionResult> SearchAndFilter([FromQuery] CourseSearchFilterDto filter)
        {
            var courses = await _courseService.SearchAndFilterCoursesAsync(filter);
            return Ok(courses);
        }

        [HttpPost]
        [Authorize]
        public async Task<IActionResult> Create([FromBody] CreateCourseDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            int newId = await _courseService.CreateCourseAsync(dto);
            return CreatedAtAction(nameof(GetById), new { id = newId }, new { courseID = newId, message = "Course created successfully." });
        }

        [HttpPut("{id}")]
        [Authorize]
        public async Task<IActionResult> Update(int id, [FromBody] UpdateCourseDto dto)
        {
            if (!ModelState.IsValid) return BadRequest(ModelState);
            var existing = await _courseService.GetCourseByIdAsync(id);
            if (existing == null) return NotFound(new { message = $"Course with ID {id} not found." });

            await _courseService.UpdateCourseAsync(id, dto);
            return Ok(new { message = "Course updated successfully." });
        }

        [HttpDelete("{id}")]
        [Authorize]
        public async Task<IActionResult> Delete(int id)
        {
            var existing = await _courseService.GetCourseByIdAsync(id);
            if (existing == null) return NotFound(new { message = $"Course with ID {id} not found." });

            await _courseService.DeleteCourseAsync(id);
            return Ok(new { message = "Course deleted successfully." });
        }
    }
}
