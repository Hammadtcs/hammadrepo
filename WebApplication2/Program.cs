var builder = WebApplication.CreateBuilder(args);
var app = builder.Build();

// 1) Look for default files like "index.html" 
app.UseDefaultFiles();

// 2) Serve static files from wwwroot
app.UseStaticFiles();

// 3) Map anything else back to index.html (SPA fallback)
app.MapFallbackToFile("index.html");

app.Run();
