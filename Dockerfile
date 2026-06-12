FROM mcr.microsoft.com/dotnet/sdk:10.0 AS builder
WORKDIR /app
COPY Anitec.Platform/*.csproj Anitec.Platform/
RUN dotnet restore ./Anitec.Platform
COPY . .
RUN dotnet publish ./Anitec.Platform -c Release -o out

FROM mcr.microsoft.com/dotnet/aspnet:10.0
WORKDIR /app
COPY --from=builder /app/out .
EXPOSE 80
ENTRYPOINT ["dotnet", "Anitec.Platform.dll"]
