unit ray_model;

{$mode objfpc}{$H+}
 //is test module
interface

uses
  ray_header, ray_math, classes;

type
  TModelDrawMode = (dmNormal, dmEx, dmWires, dmWiresEx);

  { T3DEngine }
  T3DEngine = class
   private
     FWorld: TVector3;
     FCamera: TCamera;

     procedure SetCamera(Value: TCamera3D);
     procedure SetWorldX(Value: Single);
     procedure SetWorldY(Value: Single);
   public
     List: TList;
     DeadList: TList;

     procedure Draw();
     procedure ClearDeadModel;
     procedure Move(DT: Double);

     constructor Create;
     destructor Destroy; override;

     property Camera: TCamera read FCamera write SetCamera;
     property WorldX: Single read FWorld.X write SetWorldX;
     property WorldY: Single read FWorld.Y write SetWorldY;


   end;

  { T3DModel }
  T3DModel = class
  private
    FAngle: Single;
    FAngleX: Single;
    FAngleY: Single;
    FAngleZ: Single;
    FAxis: TVector3;
    FAxisX: Single;
    FAxisY: Single;
    FAxisZ: Single;
    FColor: TColor;
    FDrawMode: TModelDrawMode;
    FScale: Single;
    FScaleEx: TVector3;
    FPosition: TVector3;
    procedure SetScale(AValue: Single);
  protected
    FEngine: T3DEngine;
    FModel: TModel;
    FTexture: TTexture2d;
  public
    IsModelDead: Boolean;
    Visible: Boolean;
    procedure Draw();
    procedure Move(DT: Double); virtual;
    procedure Dead();
    procedure ModelLoad(FileName: String);
    procedure ModelLoadTexture(FileName: String);
    constructor Create(Engine: T3DEngine); virtual;
    destructor Destroy; override;


    property AxisX: Single read FAxisX write FAxisX;
    property AxisY: Single read FAxisY write FAxisY;
    property AxisZ: Single read FAxisZ write FAxisZ;

    property Angle: Single read FAngle write FAngle;
    property AngleX: Single read FAngleX write FAngleX;
    property AngleY: Single read FAngleY write FAngleY;
    property AngleZ: Single read FAngleZ write FAngleZ;

    property X: Single read FPosition.X write FPosition.X;
    property Y: Single read FPosition.Y write FPosition.Y;
    property Z: Single read FPosition.Z write FPosition.Z;

    property Scale: Single read FScale write SetScale;
    property Color: TColor read FColor write FColor;
    property DrawMode: TModelDrawMode read FDrawMode write FDrawMode;
  end;


implementation

{ T3DModel }

procedure T3DModel.SetScale(AValue: Single);
begin
  if FScale=AValue then Exit;
  FScale:=AValue;
  Vector3Set(@FScaleEx,FScale,FScale,FScale);
end;

procedure T3DModel.Draw();
begin
  if Assigned(FEngine) then
    case FDrawMode of
    dmNormal: DrawModel(FModel, FPosition, FScale, WHITE); // Draw 3d model with texture
    dmEx: DrawModelEx(FModel, FPosition, FAxis, FAngle, FScaleEx, FColor); // Draw a model with extended parameters
    dmWires: DrawModelWires(FModel, FPosition, FScale, FColor);  // Draw a model wires (with texture if set)
    dmWiresEX: DrawModelWiresEx(FModel,FPosition,FAxis, FAngle, FScaleEx,FColor);
    end;
end;

procedure T3DModel.Move(DT: Double);
begin

  FModel.transform:=MatrixRotateXYZ(Vector3Create(DEG2RAD*FAxisX,DEG2RAD*FAxisY,DEG2RAD*FAxisZ));
   // DEG2RAD
   Vector3Set(@FAxis,FAxisX,FAxisY,FAxisZ);
end;

procedure T3DModel.Dead();
begin
   if IsModelDead = False then
  begin
    IsModelDead := True;
    FEngine.DeadList.Add(Self);
    Self.Visible := False;
  end;
end;

procedure T3DModel.ModelLoad(FileName: String);
begin
  FModel:=LoadModel(PChar(FileName));
end;

procedure T3DModel.ModelLoadTexture(FileName: String);
begin
    //FModel:=LoadModel(PChar(ModelFile));
  FTexture:= LoadTexture(PChar(FileName));
  SetMaterialTexture(FModel.materials[0], MATERIAL_MAP_DIFFUSE, FTexture);//todo
end;

constructor T3DModel.Create(Engine: T3DEngine);
begin
  FEngine := Engine;
  FEngine.List.Add(Self);
  //FModel:=LoadModel(PChar(ModelFile));
  //FTexture:= LoadTexture(PChar(TextureFile));
  //SetMaterialTexture(FModel.materials[0], MATERIAL_MAP_DIFFUSE, FTexture);//todo
  FScale:=1.0;
  FDrawMode:=dmNormal;
  FColor:=WHITE;
  FAngle:=1.0;
  FPosition:=Vector3Create(0.0,0.0,0.0);
  FAxis:=Vector3Create(0.0,0.0,0.0);
  FScaleEx:= Vector3Create(1.0,1.0,1.0);
  FAngleX:=0.0;
end;

destructor T3DModel.Destroy;
begin
  inherited Destroy;
end;

{ T3DEngine }

procedure T3DEngine.SetCamera(Value: TCamera3D);
begin
  FCamera := Value; //????????????///
end;

procedure T3DEngine.SetWorldX(Value: Single);
begin
  FWorld.X := Value;
end;

procedure T3DEngine.SetWorldY(Value: Single);
begin
  FWorld.Y := Value;
end;

procedure T3DEngine.Draw();
var
  i: Integer;
begin
  BeginMode3d(FCamera);
  for i := 0 to List.Count - 1 do
  begin
    //BeginMode3d(FCamera);
    T3DModel(List.Items[i]).Draw();

    //EndMode3d();
  end;
  DrawGrid(10, 0.5);
  EndMode3d();
end;

procedure T3DEngine.ClearDeadModel;
var
  i: Integer;
begin
  for i := 0 to DeadList.Count - 1 do
  begin
    if DeadList.Count >= 1 then
    begin
      if T3DModel(DeadList.Items[i]).IsModelDead = True then
      begin
        T3DModel(DeadList.Items[i]).FEngine.List.Remove(DeadList.Items[i]);
      end;
    end;
  end;
  DeadList.Clear;
end;

procedure T3DEngine.Move(DT: Double);
var
  i: Integer;
begin
   UpdateCamera(FCamera); // Update camera
  for i := 0 to List.Count - 1 do
  begin
    T3DModel(List.Items[i]).Move(DT);
  end;
end;

constructor T3DEngine.Create;
begin
  List := TList.Create;
  DeadList := TList.Create;

  FCamera.position := Vector3Create(3.0, 4.0, 0.0);
  FCamera.target := Vector3Create(0.0, 0.5, 0.0);
  FCamera.up := Vector3Create(0.0, 1.0, 0.0);
  FCamera.fovy := 75.0;
  FCamera.projection := CAMERA_PERSPECTIVE;
  SetCameraMode(FCamera, CAMERA_FIRST_PERSON); // Set an orbital camera mode
end;

destructor T3DEngine.Destroy;
var
  i: Integer;
begin
  for i := 0 to List.Count - 1 do
  begin
    T3DModel(List.Items[i]).Destroy;
  end;
  List.Destroy;
  DeadList.Destroy;
  inherited Destroy;
end;

end.

