using System.Threading.Tasks;
using Microsoft.AspNetCore.Authorization;
using Microsoft.AspNetCore.Mvc;
using TrainingCourses.Api.Services;

namespace TrainingCourses.Api.Controllers
{
    [ApiController]
    [Route("api/[controller]")]
    public class DashboardController : ControllerBase
    {
        private readonly IDashboardService _dashboardService;

        public DashboardController(IDashboardService dashboardService)
        {
            _dashboardService = dashboardService;
        }

        [HttpGet("kpis")]
        [AllowAnonymous]
        public async Task<IActionResult> GetKpis()
        {
            var kpis = await _dashboardService.GetDashboardKpisAsync();
            return Ok(kpis);
        }

        [HttpGet("charts/categories")]
        [AllowAnonymous]
        public async Task<IActionResult> GetCategoryChart()
        {
            var chart = await _dashboardService.GetCategoryChartAsync();
            return Ok(chart);
        }

        [HttpGet("popular-courses")]
        [AllowAnonymous]
        public async Task<IActionResult> GetPopularCourses([FromQuery] int limit = 5)
        {
            var courses = await _dashboardService.GetPopularCoursesAsync(limit);
            return Ok(courses);
        }
    }
}
