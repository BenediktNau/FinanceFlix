FROM mcr.microsoft.com/dotnet/aspnet:10.0 AS base
USER $APP_UID
WORKDIR /app
EXPOSE 8080
EXPOSE 8081

FROM mcr.microsoft.com/dotnet/sdk:10.0 AS build
ARG BUILD_CONFIGURATION=Release
RUN apt-get update && apt-get install -y clang zlib1g-dev
WORKDIR /src
COPY ["FinanceFlix/FinanceFlix.csproj", "FinanceFlix/"]
RUN dotnet restore "FinanceFlix/FinanceFlix.csproj"
COPY . .
WORKDIR "/src/FinanceFlix"
RUN dotnet build "./FinanceFlix.csproj" -c $BUILD_CONFIGURATION -o /app/build

FROM build AS publish
ARG BUILD_CONFIGURATION=Release
RUN dotnet publish "./FinanceFlix.csproj" -c $BUILD_CONFIGURATION -o /app/publish /p:UseAppHost=false

FROM base AS final
WORKDIR /app
COPY --from=publish /app/publish .
ENTRYPOINT ["dotnet", "FinanceFlix.dll"]
