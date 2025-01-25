FROM mcr.microsoft.com/dotnet/aspnet:9.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

RUN apt-get update && \
    apt-get install -y nano && \
    rm -rf /var/lib/apt/lists/*

FROM mcr.microsoft.com/dotnet/sdk:9.0 AS build
ARG BUILD_CONFIGURATION=Release
WORKDIR /src
COPY ["src/UrlShortner.API/UrlShortner.API.csproj", "src/UrlShortner.API/"]

RUN dotnet restore "./src/UrlShortner.API/UrlShortner.API.csproj"
COPY . .
WORKDIR "/src/src/UrlShortner.API"
RUN dotnet build "./UrlShortner.API.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./UrlShortner.API.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "UrlShortner.API.dll"]
