{
  lib,
  buildDotnetModule,
  fetchFromGitHub,
  dotnetCorePackages,
  nix-update-script,
}:
buildDotnetModule rec {
  pname = "garnet";
  version = "1.0.13";

  src = fetchFromGitHub {
    owner = "microsoft";
    repo = "garnet";
    rev = "v${version}";
    hash = "sha256-mAZBYVOAbVPKcOpt+vA4uEK+xEx4qXPnAthsPsxiXkw=";
  };

  projectFile = "main/GarnetServer/GarnetServer.csproj";
  nugetDeps = ./deps.nix;

  dotnet-sdk = dotnetCorePackages.sdk_8_0;
  dotnet-runtime = dotnetCorePackages.runtime_8_0;

  dotnetBuildFlags = [
    "-f"
    "net8.0"
  ];
  dotnetInstallFlags = dotnetBuildFlags;

  passthru = {
    updateScript = nix-update-script { };
  };

  meta = {
    description = "Remote cache-store from Microsoft Research";
    longDescription = ''
      A remote cache-store that offers strong performance, scalability,
      storage, recovery, cluster sharding, key migration, replication features,
      and compatibility with existing Redis clients
    '';
    homepage = "https://microsoft.github.io/garnet/";
    changelog = "https://github.com/microsoft/garnet/releases/tag/v${version}";
    license = lib.licenses.mit;
    maintainers = with lib.maintainers; [ getchoo ];
    mainProgram = "GarnetServer";
  };
}
