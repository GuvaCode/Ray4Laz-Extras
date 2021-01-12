unit ray_model;

{$mode objfpc}{$H+}

interface

uses
  ray_headers, classes;

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
    FAxis: TVector3;
    FColor: TColor;
    FDrawMode: TModelDrawMode;
    FScale: Single;
    FScaleEx: TVector3;
    FPosition: TVector3;
    procedure SetAngle(AValue: Single);
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
    constructor Create(Engine: T3DEngine; ModelFile:String; TextureFile:String); virtual;
    destructor Destroy; override;

    property Angle: Single read FAngle write SetAngle;
    property AxisX: Single read FAxis.X write FAxis.X;
    property AxisY: Single read FAxis.Y write FAxis.Y;
    property AxisZ: Single read FAxis.Z write FAxis.Z;
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

procedure T3DModel.SetAngle(AValue: Single);
begin
  if FAngle=AValue then Exit;
  FAngle:=AValue;
end;

procedure T3DModel.Draw();
begin
  if Assigned(FEngine) then
    case FDrawMode of
    dmNormal: DrawModel(FModel, FPosition, FScale, WHITE); // Draw 3d model with texture
    dmEx: DrawModelEx(FModel, FPosition, FAxis, FAngle, FScaleEx, FColor); // Draw a model with extended parameters
    dmWires: DrawModelWires(FModel,FPosition,FScale,FColor);  // Draw a model wires (with texture if set)
    dmWiresEX: DrawModelWiresEx(FModel,FPosition,FAxis,FAngle,FScaleEx,FColor);
    end;
end;

procedure T3DModel.Move(DT: Double);
begin

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

constructor T3DModel.Create(Engine: T3DEngine; ModelFile: String;
  TextureFile: String);
begin
  FEngine := Engine;
  FEngine.List.Add(Self);
  FModel:=LoadModel(PChar(ModelFile));
  FTexture:= LoadTexture(PChar(TextureFile));
  SetMaterialTexture(@FModel.materials[0], MAP_DIFFUSE, FTexture);//todo
  FScale:=1.0;
  FDrawMode:=dmNormal;
  FColor:=WHITE;
  FAngle:=1.0;
  FAxis:=Vector3Create(1.0,1.0,1.0);
  FScaleEx:= Vector3Create(1.0,1.0,1.0);
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
    DrawGrid(10, 0.5);
    //EndMode3d();
  end;
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
   UpdateCamera(@FCamera); // Update camera
  for i := 0 to List.Count - 1 do
  begin
    T3DModel(List.Items[i]).Move(DT);
  end;
end;

constructor T3DEngine.Create;
begin
  List := TList.Create;
  DeadList := TList.Create;

  FCamera.position := Vector3Create(3.0, 3.0, 3.0);
  FCamera.target := Vector3Create(0.0, 1.5, 0.0);
  FCamera.up := Vector3Create(0.0, 1.0, 0.0);
  FCamera.fovy := 65.0;
  FCamera._type := CAMERA_PERSPECTIVE;
  SetCameraMode(FCamera, CAMERA_THIRD_PERSON); // Set an orbital camera mode
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

