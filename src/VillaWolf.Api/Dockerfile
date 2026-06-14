# Multi-stage build for the Villa Wolf API.
FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
WORKDIR /src

# Restore against the project files first to maximize layer caching.
COPY ["Directory.Build.props", "./"]
COPY ["src/VillaWolf.Domain/VillaWolf.Domain.csproj", "src/VillaWolf.Domain/"]
COPY ["src/VillaWolf.Application/VillaWolf.Application.csproj", "src/VillaWolf.Application/"]
COPY ["src/VillaWolf.Infrastructure/VillaWolf.Infrastructure.csproj", "src/VillaWolf.Infrastructure/"]
COPY ["src/VillaWolf.Api/VillaWolf.Api.csproj", "src/VillaWolf.Api/"]
RUN dotnet restore "src/VillaWolf.Api/VillaWolf.Api.csproj"

COPY . .
RUN dotnet publish "src/VillaWolf.Api/VillaWolf.Api.csproj" -c Release -o /app/publish /p:UseAppHost=false

FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS final
WORKDIR /app
COPY --from=build /app/publish .
ENV ASPNETCORE_URLS=http://+:8080
EXPOSE 8080
ENTRYPOINT ["dotnet", "VillaWolf.Api.dll"]
