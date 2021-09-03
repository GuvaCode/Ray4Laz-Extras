unit ray4lazex_desc2d;
{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazIDEIntf, ProjectIntf, Controls, Forms;

type
    { TSpriteEngineApplicationDescriptor }
    TSpriteEngineApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

    { TSpriteEngineFileUnit }
    TSpriteEngineFileUnit = class(TFileDescPascalUnit)
  public
    constructor Create; override;
    function GetInterfaceUsesSection: string; override;
    function GetUnitDirectives: string; override;
    function GetImplementationSource(const Filename, SourceName, ResourceName: string): string; override;
    function GetInterfaceSource(const aFilename, aSourceName, aResourceName: string): string; override;
    end;

     const LE = #10;

 procedure Register;

 resourcestring
   AboutPrj = 'Ray SpriteEngine Game Application';
   AboutDsc='The Ray Game Framework is a set of classes for helping in the creation of 2D and 3D games in pascal.';



implementation

procedure Register;
begin
  RegisterProjectFileDescriptor(TSpriteEngineFileUnit.Create,FileDescGroupName);
  RegisterProjectDescriptor(TSpriteEngineApplicationDescriptor.Create);
end;

function FileDescriptorByName() : TProjectFileDescriptor;
begin
  Result:=ProjectFileDescriptors.FindByName('RGA2d_Unit');
end;

{ TSpriteEngineFileUnit }
constructor TSpriteEngineFileUnit.Create;
begin
   inherited Create;
  Name:='RGA2d_Unit';
  UseCreateFormStatements:=False;
end;

function TSpriteEngineFileUnit.GetInterfaceUsesSection: string;
begin
    Result:='cmem, ray_header, ray_application, ray_sprite_engine'
end;

function TSpriteEngineFileUnit.GetUnitDirectives: string;
begin
  result := '{$mode objfpc}{$H+} '
end;

function TSpriteEngineFileUnit.GetImplementationSource(const Filename, SourceName,
  ResourceName: string): string;
begin
    Result:=
  'constructor TGame.Create;'+LE+
  'begin'+LE+
  ' //setup and initialization engine' +LE+
  ' InitWindow(800, 600, ''raylib [Game Project]''); // Initialize window and OpenGL context '+LE+
  ' SetWindowState(FLAG_VSYNC_HINT or FLAG_MSAA_4X_HINT); // Set window configuration state using flags'+LE+
  ' SetTargetFPS(60); // Set target FPS (maximum)' +LE+
  ' ClearBackgroundColor:= BLACK; // Set background color (framebuffer clear color)'+LE+
  ' // Greate the sprite engine and texture image list '+LE+
  ' SpriteEngine:=TSpriteEngine.Create;'+LE+
  ' GameTexture:= TGameTexture.Create;'+LE+
  'end;'+LE+
  ''+LE+
  'procedure TGame.Update;'+LE+
  'begin'+LE+
  ' SpriteEngine.ClearDeadSprites;  // cleaning dead sprites' +LE+
  ' SpriteEngine.Move(GetFrameTime); // move all sprites in SpriteEngine'+LE+
  'end;'+LE+
  ''+LE+
  'procedure TGame.Render;'+LE+
  'begin'+LE+
  ' BeginMode2D(Camera2D);'+LE+
  ' SpriteEngine.Draw;'+LE+
  ' EndMode2D;'+LE+
  ' DrawFPS(10,10); // Draw current FPS'+LE+
  'end;'+LE+
  ''+LE+
  'procedure TGame.Resized;'+LE+
  'begin'+LE+
  ' SpriteEngine.VisibleWidth:=GetScreenWidth;'+LE+
  ' SpriteEngine.VisibleHeight:=GetScreenHeight;'+LE+
  'end;'+LE+
  ''+LE+
  'procedure TGame.Shutdown;'+LE+
  'begin'+LE+
  ' SpriteEngine.Free;'+LE+
  ' GameTexture.Free;'+LE+
  'end;' +LE+LE;

end;

function TSpriteEngineFileUnit.GetInterfaceSource(const aFilename, aSourceName,
  aResourceName: string): string;
begin
   Result:=
'type'+LE+
'TGame = class(TRayApplication)'+LE+
'  private'+LE+
'  protected'+LE+
'  public'+LE+
'    SpriteEngine: TSpriteEngine;'+LE+
'    GameTexture: TGameTexture;'+LE+
'    Camera2D: TCamera2D;'+LE+
'    constructor Create; override;'+LE+
'    procedure Update; override;'+LE+
'    procedure Render; override;'+LE+
'    procedure Shutdown; override;'+LE+
'    procedure Resized; override;'+LE+
'  end;'+LE+LE
end;

{ TSpriteEngineApplicationDescriptor }

constructor TSpriteEngineApplicationDescriptor.Create;
begin
  inherited Create;
  Name := AboutDsc;
end;

function TSpriteEngineApplicationDescriptor.GetLocalizedName: string;
begin
  Result := AboutPrj;
end;

function TSpriteEngineApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result := AboutDsc;
end;

function TSpriteEngineApplicationDescriptor.InitProject(AProject: TLazProject
  ): TModalResult;
var
  NewSource: String;
  MainFile: TLazProjectFile;
begin
  Result:=inherited InitProject(AProject);

  MainFile:=AProject.CreateProjectFile('myGame.lpr');
  MainFile.IsPartOfProject:=true;
  AProject.AddFile(MainFile,false);
  AProject.MainFileID:=0;
  AProject.UseAppBundle:=true;
 // AProject.LoadDefaultIcon;
 // AProject.LazCompilerOptions.SyntaxMode:='Delphi';

   // create program source
  NewSource:=
  'program Game1;'+LE+
   ''+LE+
  'uses'+LE+
  '   SysUtils;'+LE+
  ''+LE+
  ''+LE+
  'var Game: TGame;'+LE+
  ''+LE+
  'begin'+LE+
  '  Game:= TGame.Create;'+LE+
  '  Game.Run;'+LE+
  '  Game.Free;'+LE+
  'end.'+LE;

  AProject.MainFile.SetSourceText(NewSource,true);
  AProject.AddPackageDependency('ray4laz');
  AProject.AddPackageDependency('ray4laz_extra');
  AProject.LazCompilerOptions.UnitOutputDirectory:='lib'+PathDelim+'$(TargetCPU)-$(TargetOS)';
  AProject.LazCompilerOptions.TargetFilename:='Game';
 //AProject.LazCompilerOptions.Win32GraphicApp:=True;
 //AProject.LazCompilerOptions.GenerateDebugInfo:=False;
end;



function TSpriteEngineApplicationDescriptor.CreateStartFiles(AProject: TLazProject
  ): TModalResult;
begin
  Result:=LazarusIDE.DoNewEditorFile(FileDescriptorByName,'','',[nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
end;


end.

