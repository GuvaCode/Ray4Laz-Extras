unit ray4lazEx_desc;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, LazIDEIntf, ProjectIntf, Controls, Forms;

type

    { TRgfApplicationDescriptor }

    TRgfApplicationDescriptor = class(TProjectDescriptor)
  public
    constructor Create; override;
    function GetLocalizedName: string; override;
    function GetLocalizedDescription: string; override;
    function InitProject(AProject: TLazProject): TModalResult; override;
    function CreateStartFiles(AProject: TLazProject): TModalResult; override;
  end;

    { TRgfFileUnit }

    TRgfFileUnit = class(TFileDescPascalUnit)
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
   AboutPrj = 'Ray Game Application';
   AboutDsc='The Ray Game Framework is a set of classes for helping in the creation of 2D and 3D games in pascal.';



implementation

procedure Register;
begin
   RegisterProjectFileDescriptor(TRgfFileUnit.Create,FileDescGroupName);
  RegisterProjectDescriptor(TRgfApplicationDescriptor.Create);
end;
 function FileDescriptorByName() : TProjectFileDescriptor;
begin
  Result:=ProjectFileDescriptors.FindByName('RGA_Unit');
end;
{ TRgfFileUnit }

constructor TRgfFileUnit.Create;
begin
   inherited Create;
  Name:='RGA_Unit';
  UseCreateFormStatements:=False;
end;

function TRgfFileUnit.GetInterfaceUsesSection: string;
begin
    Result:='cmem, ray_header, ray_application, math'
end;

function TRgfFileUnit.GetUnitDirectives: string;
begin
  result := '{$mode objfpc}{$H+} '
end;

function TRgfFileUnit.GetImplementationSource(const Filename, SourceName,
  ResourceName: string): string;
begin
    Result:=
  'constructor TGame.Create;'+LE+
  'begin'+LE+
  '  inherited;'+LE+
  ''+LE+
  'end;'+LE+
  ''+LE+
  'procedure TGame.Init;'+LE+
  'begin'+LE+
  'end;'+LE+
  ''+LE+
  'procedure TGame.Update;'+LE+
  'begin'+LE+
  'end;'+LE+
  ''+LE+
  'procedure TGame.Render;'+LE+
  'begin'+LE+
  'end;'+LE+
  ''+LE+
  'procedure TGame.Shutdown;'+LE+
  'begin'+LE+
  'end;' +LE+LE;

end;

function TRgfFileUnit.GetInterfaceSource(const aFilename, aSourceName,
  aResourceName: string): string;
begin
   Result:=
'type'+LE+
'TGame = class(TRayApplication)'+LE+
'  private'+LE+
'  protected'+LE+
'  public'+LE+
'    constructor Create; override;'+LE+
'    procedure Init; override;'+LE+
'    procedure Update; override;'+LE+
'    procedure Render; override;'+LE+
'    procedure Shutdown; override;'+LE+
'  end;'+LE+LE
end;

{ TRgfApplicationDescriptor }

constructor TRgfApplicationDescriptor.Create;
begin
  inherited Create;
  Name := AboutPrj;
end;

function TRgfApplicationDescriptor.GetLocalizedName: string;
begin
  Result := AboutPrj;
end;

function TRgfApplicationDescriptor.GetLocalizedDescription: string;
begin
  Result := AboutPrj+LE+LE+AboutDsc;
end;

function TRgfApplicationDescriptor.InitProject(AProject: TLazProject
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
//  AProject.LazCompilerOptions.Win32GraphicApp:=True;
//AProject.LazCompilerOptions.GenerateDebugInfo:=False;

end;



function TRgfApplicationDescriptor.CreateStartFiles(AProject: TLazProject
  ): TModalResult;
begin
  Result:=LazarusIDE.DoNewEditorFile(FileDescriptorByName,'','',[nfIsPartOfProject,nfOpenInEditor,nfCreateDefaultSrc]);
end;


end.

