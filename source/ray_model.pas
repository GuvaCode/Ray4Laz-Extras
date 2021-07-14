unit ray_model;

{$mode objfpc}{$H+}
 //is test module
interface

uses
  ray_header, ray_math, classes;

type
  TModelDrawMode = (dmNormal, dmEx, dmWires, dmWiresEx);
  TModelEngineCameraMode = (cmCustom, cmFree, cmOrbital, cmFirstPerson, cmThirdPerson);

  { TModelEngine }
  TModelEngine = class
   private
     FEngineCameraMode: TModelEngineCameraMode;
     FEngineCameraPosition: TVector3;
     FGridSlices: longint;
     FGridSpacing: single;
     FWorld: TVector3;
     FCamera: TCamera;
     FDrawsGrid: Boolean;

     procedure SetCamera(AValue: TCamera);
     procedure SetDrawsGrid(AValue: boolean);
     procedure SetEngineCameraMode(AValue: TModelEngineCameraMode);
     procedure SetEngineCameraPosition(AValue: TVector3);
     procedure SetGridSlices(AValue: longint);
     procedure SetGridSpacing(AValue: single);
     procedure SetWorldX(Value: Single);
     procedure SetWorldY(Value: Single);
   public
     List: TList;
     DeadList: TList;

     procedure Draw();
     procedure ClearDeadModel;
     procedure Move(MoveCount: Double);

     constructor Create;
     destructor Destroy; override;

     property Camera: TCamera read FCamera write SetCamera;

     property WorldX: Single read FWorld.X write SetWorldX;
     property WorldY: Single read FWorld.Y write SetWorldY;
     property DrawsGrid:boolean read FDrawsGrid write SetDrawsGrid;
     property GridSlices:longint read FGridSlices write SetGridSlices;
     property GridSpacing: single read FGridSpacing write SetGridSpacing;
     property EngineCameraMode: TModelEngineCameraMode read FEngineCameraMode write SetEngineCameraMode;
     property EngineCameraPosition: TVector3 read FEngineCameraPosition write SetEngineCameraPosition;
  end;

  { T3dModel }
  T3dModel = class
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
    FAnims : PModelAnimation;
    procedure SetScale(AValue: Single);
  protected
    FEngine: TModelEngine;
    FModel: TModel;
    FTexture: TTexture2d;
  public
    IsModelDead: Boolean;
    Visible: Boolean;
    procedure Draw();
    procedure Move(MoveCount: Double); virtual;
    procedure Dead();
    procedure Load3dModel(FileName: String);
    procedure Load3dModelTexture(FileName: String);
    procedure Load3dModelAnimations(FileName:String; AnimCoint:integer);
    procedure Update3dModelAnimations(Frame:longint);

    constructor Create(Engine: TModelEngine); virtual;
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
    property Anims: PModelAnimation read FAnims write FAnims;
  end;


implementation

{ T3dModel }

procedure T3dModel.SetScale(AValue: Single);
begin
  if FScale=AValue then Exit;
  FScale:=AValue;
  Vector3Set(@FScaleEx,FScale,FScale,FScale);
end;

procedure T3dModel.Draw();
begin
  if Assigned(FEngine) then
    case FDrawMode of
    dmNormal: DrawModel(FModel, FPosition, FScale, WHITE); // Draw 3d model with texture
    dmEx: DrawModelEx(FModel, FPosition, FAxis, FAngle, FScaleEx, FColor); // Draw a model with extended parameters
    dmWires: DrawModelWires(FModel, FPosition, FScale, FColor);  // Draw a model wires (with texture if set)
    dmWiresEX: DrawModelWiresEx(FModel,FPosition,FAxis, FAngle, FScaleEx,FColor);
    end;
end;

procedure T3dModel.Move(MoveCount: Double);
begin
   FModel.transform:=MatrixRotateXYZ(Vector3Create(DEG2RAD*FAxisX,DEG2RAD*FAxisY,DEG2RAD*FAxisZ));
   // DEG2RAD
   Vector3Set(@FAxis,FAxisX,FAxisY,FAxisZ);
end;

procedure T3dModel.Dead();
begin
   if IsModelDead = False then
  begin
    IsModelDead := True;
    FEngine.DeadList.Add(Self);
    Self.Visible := False;
  end;
end;

procedure T3dModel.Load3dModel(FileName: String);
begin
  FModel:=LoadModel(PChar(FileName));
end;

procedure T3dModel.Load3dModelTexture(FileName: String);
begin
  FTexture:= LoadTexture(PChar(FileName));
  SetMaterialTexture(FModel.materials[0], MATERIAL_MAP_DIFFUSE, FTexture);//todo
end;

procedure T3dModel.Load3dModelAnimations(FileName: String; AnimCoint: integer);
begin
   FAnims:=LoadModelAnimations(PChar(FileName),AnimCoint);
end;

procedure T3dModel.Update3dModelAnimations(Frame: longint);
begin
  UpdateModelAnimation(FModel,FAnims[0],Frame);
end;

constructor T3dModel.Create(Engine: TModelEngine);
begin
  FEngine := Engine;
  FEngine.List.Add(Self);
  FScale:=1.0;
  FDrawMode:=dmNormal;
  FColor:=WHITE;
  FAngle:=1.0;
  FPosition:=Vector3Create(0.0,0.0,0.0);
  FAxis:=Vector3Create(0.0,0.0,0.0);
  FScaleEx:= Vector3Create(1.0,1.0,1.0);
  FAngleX:=0.0;
end;

destructor T3dModel.Destroy;
begin
  UnloadTexture(Self.FTexture);
  UnloadModel(Self.FModel);
  inherited Destroy;
end;

procedure TModelEngine.SetCamera(AValue: TCamera);
begin
  FCamera:=AValue;
end;




procedure TModelEngine.SetDrawsGrid(AValue: boolean);
begin
  FDrawsGrid:= AValue;
end;

procedure TModelEngine.SetEngineCameraMode(AValue: TModelEngineCameraMode);
begin
  if FEngineCameraMode=AValue then Exit;
  FEngineCameraMode:=AValue;
  case FEngineCameraMode of
    cmCustom         :SetCameraMode(FCamera, CAMERA_CUSTOM);
    cmFree           :SetCameraMode(FCamera, CAMERA_FREE);
    cmOrbital        :SetCameraMode(FCamera, CAMERA_ORBITAL);
    cmFirstPerson    :SetCameraMode(FCamera, CAMERA_FIRST_PERSON);
    cmThirdPerson    :SetCameraMode(FCamera, CAMERA_THIRD_PERSON);
  end;

end;

procedure TModelEngine.SetEngineCameraPosition(AValue: TVector3);
begin
 // if FEngineCameraPosition=AValue then Exit;
  FEngineCameraPosition:=AValue;
//  FCamera.position:=FEngineCameraPosition;
  FCamera.target:=FEngineCameraPosition;
end;

procedure TModelEngine.SetGridSlices(AValue: longint);
begin
  if FGridSlices=AValue then Exit;
  FGridSlices:=AValue;
end;

procedure TModelEngine.SetGridSpacing(AValue: single);
begin
  if FGridSpacing=AValue then Exit;
  FGridSpacing:=AValue;
end;

procedure TModelEngine.SetWorldX(Value: Single);
begin
  FWorld.X := Value;
end;

procedure TModelEngine.SetWorldY(Value: Single);
begin
  FWorld.Y := Value;
end;

procedure TModelEngine.Draw();
var
  i: Integer;
begin
  BeginMode3d(FCamera);
  for i := 0 to List.Count - 1 do
  begin
    T3dModel(List.Items[i]).Draw();
  end;
  if FDrawsGrid then DrawGrid(FGridSlices, FGridSpacing);
  EndMode3d();
end;

procedure TModelEngine.ClearDeadModel;
var
  i: Integer;
begin
  for i := 0 to DeadList.Count - 1 do
  begin
    if DeadList.Count >= 1 then
    begin
      if T3dModel(DeadList.Items[i]).IsModelDead = True then
      begin
        T3dModel(DeadList.Items[i]).FEngine.List.Remove(DeadList.Items[i]);
      end;
    end;
  end;
  DeadList.Clear;
end;

procedure TModelEngine.Move(MoveCount: Double);
var
  i: Integer;
begin
   UpdateCamera(FCamera); // Update camera
  for i := 0 to List.Count - 1 do
  begin
    T3dModel(List.Items[i]).Move(MoveCount);
  end;
end;

constructor TModelEngine.Create;
begin
  List := TList.Create;
  DeadList := TList.Create;
  FCamera.position := Vector3Create(3.0, 4.0, 0.0);
  FCamera.target := Vector3Create(0.0, 0.5, 0.0);
  FCamera.up := Vector3Create(0.0, 1.0, 0.0);
  FCamera.fovy := 75.0;
  FCamera.projection := CAMERA_PERSPECTIVE;
  SetEngineCameraMode(cmCustom);
  FGridSpacing:=0.5;
  FGridSlices:=10;
end;

destructor TModelEngine.Destroy;
var
  i: Integer;
begin
  for i := 0 to List.Count - 1 do
  begin
    T3dModel(List.Items[i]).Destroy;
  end;
  List.Destroy;
  DeadList.Destroy;
  inherited Destroy;
end;

end.

