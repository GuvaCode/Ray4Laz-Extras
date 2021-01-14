unit ray_sprites;

{$mode objfpc}{$H+}
interface

uses ray_headers, ray_math, classes;

type
  TJumpState = (jsNone, jsJumping, jsFalling);

  { T2DEngine }
  T2DEngine = class
  private
    FCamera: TCamera2D;
    FWorld: TVector3;
    procedure SetCamera(AValue: TCamera2D);
    procedure SetWorldX(Value: Single);
    procedure SetWorldY(Value: Single);
  public
    List: TList;
    DeadList: TList;
    procedure Draw();
    procedure ClearDeadSprites;
    procedure Move(MoveCount:Double);
    procedure SetZOrder();
    constructor Create;
    destructor Destroy; override;
    property Camera: TCamera2D read FCamera write SetCamera;
    property WorldX: Single read FWorld.X write SetWorldX;
    property WorldY: Single read FWorld.Y write SetWorldY;
  end;

  TPattern = record
    Height, Width: Integer;
  end;

  { TGameTexture }
  TGameTexture = class
  public
    Count: Integer;
    TextureName: array of string;
    Texture: array of TTexture2D;
    Pattern: array of TPattern;
    function LoadFromFile(FileName: String; Width, Height: Integer): Boolean;
    constructor Create;
    destructor Destroy; override;
   end;

  { TRaySprite }
  TRaySprite = class
  private
    FAnimated: Boolean;
    FVector: TVector3;
    FZ: Single;
    FScale: Single;
  protected
    FEngine: T2DEngine;
    FTextureName: string;
    FTextureIndex: Integer;
    procedure SetTextureName(Value: string);
    procedure SetTextureIndex(Value: Integer);
  public
    FTexture: TGameTexture;
    Alpha: Byte;
    Angle: Single;
    IsSpriteDead: Boolean;
    DrawMode: Integer;
    ScaleX, ScaleY: Single;
    Visible: Boolean;
    VisibleArea: TRect;
    Pattern: TNPatchInfo;
    procedure Draw();
    procedure Move(MoveCount: Double); virtual;
    procedure Dead();
    procedure SetOrder(Value: Single);
    procedure SetScale(Value: Single);
    constructor Create(Engine: T2DEngine; Texture: TGameTexture); virtual;
    constructor CreateEx(Engine: T2DEngine; Texture: TGameTexture); virtual;
    destructor Destroy; override;
    property TextureIndex: Integer read FTextureIndex write SetTextureIndex;
    property TextureName: string read FTextureName write SetTextureName;
    property X: Single read FVector.X write FVector.X;
    property Y: Single read FVector.Y write FVector.Y;
    property Z: Single read FZ write SetOrder;
    property Scale: Single read FScale write SetScale;
  end;

implementation

{ TRaySprite }
procedure TRaySprite.SetTextureName(Value: string);
var i: Integer;
begin
  FTextureName := Value;
  for i := 0 to Length(FTexture.TextureName) - 1 do
  begin
    if lowercase(FTextureName) = lowercase(FTexture.TextureName[i]) then
    begin
      TextureIndex := i;
      Pattern.Right := FTexture.Pattern[i].Height;
      Pattern.Bottom := FTexture.Pattern[i].Width;
      Exit;
    end;
  end;
  TextureIndex := -1;
end;

procedure TRaySprite.SetTextureIndex(Value: Integer);
begin
  FTextureIndex := Value;
  Pattern.Right := FTexture.Pattern[FTextureIndex].Height;
  Pattern.Bottom := FTexture.Pattern[FTextureIndex].Width;
end;

procedure TRaySprite.Draw();
var Source: TRectangle;
    Dest: TRectangle;
    Pos:TVector2;
begin
   if TextureIndex <> -1 then
  begin
    if Assigned(FEngine) then
    begin
      if X > (FEngine.WorldX) + VisibleArea.Left then
      begin
        // pattern
        if X + Pattern.Right < (FEngine.WorldX) + VisibleArea.Right + 300 then
        begin
          if Y > (FEngine.WorldY) + VisibleArea.Top then
          begin
            // pattern
            if Y + Pattern.Bottom < (FEngine.WorldY) + VisibleArea.Bottom + 300 then
            begin
              if Visible then
              begin
                if DrawMode = 0 then
                begin
                  Source:=RectangleCreate(0,0,FTexture.Pattern[FTextureIndex].Width,
                  FTexture.Pattern[FTextureIndex].Height);

                  Dest:=RectangleCreate(FEngine.FCamera.target.X + X,
                  FEngine.FCamera.target.X + Y,FTexture.Pattern[FTextureIndex].Width,

                  FTexture.Pattern[FTextureIndex].Height);

                  Pos:=Vector2Create(FEngine.FCamera.target.X + X, FEngine.FCamera.target.X + Y);

                  DrawTexturePro(FTexture.Texture[FTextureIndex], Source, Dest, Pos, 0, WHITE);

                  {DrawTexture(FTexture.Texture[FTextureIndex],
                  round(FEngine.FCamera.target.x + X),
                  round(FEngine.FCamera.target.y + Y),WHITE);}

                  { ssprite2d_Draw(FTexture.Texture[FTextureIndex],
                    FEngine.FCamera.X + X, FEngine.FCamera.Y + Y,
                    FTexture.Pattern[FTextureIndex].Width,
                    FTexture.Pattern[FTextureIndex].Height, Angle, Alpha);}
                end;

                if DrawMode = 1 then
                begin
                {DrawTexture(FTexture.Texture[FTextureIndex],
                  round(FEngine.FCamera.target.x + X),
                  round(FEngine.FCamera.target.y + Y),BLACK); }
               {   fx2d_SetScale(ScaleX, ScaleY);
                  ssprite2d_Draw(FTexture.Texture[FTextureIndex],
                    FEngine.FCamera.X + X, FEngine.FCamera.Y + Y,
                    FTexture.Pattern[FTextureIndex].Width,
                    FTexture.Pattern[FTextureIndex].Height, Angle, Alpha,
                    FX2D_SCALE);}
                end;
              end;
            end;
          end;
        end;
      end;
    end
    else
    begin
      if Visible then
      begin
        if DrawMode = 0 then
        begin
        {   DrawTexture(FTexture.Texture[FTextureIndex],
                  round( X),
                  round( Y),BLACK);}
          { ssprite2d_Draw(FTexture.Texture[FTextureIndex], X, Y,
            FTexture.Pattern[FTextureIndex].Width,
            FTexture.Pattern[FTextureIndex].Height, Angle, Alpha); }
        end;
        if DrawMode = 1 then
        begin
         {  fx2d_SetScale(ScaleX, ScaleY);
            ssprite2d_Draw(FTexture.Texture[FTextureIndex], X, Y,
            FTexture.Pattern[FTextureIndex].Width,
            FTexture.Pattern[FTextureIndex].Height, Angle, Alpha, FX2D_SCALE); }
        end;
      end;
    end;
  end;
end;

procedure TRaySprite.Move(MoveCount: Double);
begin

end;

procedure TRaySprite.Dead();
begin
   if IsSpriteDead = False then
  begin
    IsSpriteDead := True;
    FEngine.DeadList.Add(Self);
    Self.Visible := False;
  end;
end;

procedure TRaySprite.SetOrder(Value: Single);
begin
  if FZ <> Value then FZ := Value;
  FEngine.SetZOrder;
end;

procedure TRaySprite.SetScale(Value: Single);
begin
  FScale := Value;
  ScaleX := FScale;
  ScaleY := FScale;
end;

constructor TRaySprite.Create(Engine: T2DEngine; Texture: TGameTexture);
begin
  FAnimated := False;
  FEngine := Engine;
  FEngine.List.Add(Self);
  FTexture := Texture;
  Pattern.Left := 0;
  Pattern.Top := 0;
  Alpha := 255;
  ScaleX := 1.0;
  ScaleY := 1.0;
  Visible := True; // Displaymode Width/Height
  VisibleArea := Rect(-300, -300, 800, 600);
end;

constructor TRaySprite.CreateEx(Engine: T2DEngine; Texture: TGameTexture);
begin
  FAnimated := False;
  FTexture := Texture;
  FEngine := Engine;
  Pattern.Left := 0;
  Pattern.Top := 0;
  Alpha := 255;
  ScaleX := 1.0;
  ScaleY := 1.0;
  Visible := True;
  VisibleArea := Rect(-300, -300, 800, 600);
end;

destructor TRaySprite.Destroy;
begin
  inherited Destroy;
end;

{ TGameTexture }
function TGameTexture.LoadFromFile(FileName: String; Width, Height: Integer): Boolean;
begin
   if not fileexists(PChar(FileName)) then
  begin
    Result := False;
    Exit;
  end;
  SetLength(Texture, Count + 1);
  SetLength(TextureName, Count + 1);
  SetLength(Pattern, Count + 1);
  Inc(Count);
  TextureName[Count - 1] := FileName;
  Pattern[Count - 1].Height := Height;
  Pattern[Count - 1].Width := Width;
  Texture[Count - 1] := LoadTexture(PChar(FileName));
//  tex_SetFrameSize(Texture[Count - 1], Width, Height);
  Result := True
end;

constructor TGameTexture.Create;
begin
end;

destructor TGameTexture.Destroy;
var
  i: Integer;
begin
  for i := 0 to Count - 1 do
  begin
    TextureName[i] := '';
    //Texture[i] := @nil;
    Pattern[i].Height := 0;
    Pattern[i].Width := 0;
  end;
  SetLength(TextureName, 0);
  SetLength(Texture, 0);
  SetLength(Pattern, 0);
  Count := 0;
  inherited Destroy;
end;

{ T2DEngine }
procedure T2DEngine.SetCamera(AValue: TCamera2D);
begin
  FCamera := AValue;
end;

procedure T2DEngine.SetWorldX(Value: Single);
begin
  FWorld.X := Value;
end;

procedure T2DEngine.SetWorldY(Value: Single);
begin
  FWorld.Y := Value;
end;

procedure T2DEngine.Draw();
var  i: Integer;
begin
 for i := 0 to List.Count - 1 do
   begin
    if TRaySprite(List.Items[i]).FAnimated = False then TRaySprite(List.Items[i]).Draw
    else// TZenAnimatedSprite(List.Items[i]).Draw;
   end;
end;

procedure T2DEngine.ClearDeadSprites;
var i: Integer;
begin
  for i := 0 to DeadList.Count - 1 do
  begin
    if DeadList.Count >= 1 then
    begin
      if TRaySprite(DeadList.Items[i]).IsSpriteDead = True then
      begin
        TRaySprite(DeadList.Items[i]).FEngine.List.Remove(DeadList.Items[i]);
      end;
    end;
  end;
  DeadList.Clear;
end;

procedure T2DEngine.Move(MoveCount: Double);
var i: Integer;
begin
  for i := 0 to List.Count - 1 do
  begin
    if TRaySprite(List.Items[i]).FAnimated = False then
       TRaySprite(List.Items[i]).Move(MoveCount)
    else
     // TZenAnimatedSprite(List.Items[i]).Move(MoveCount);
  end;
  end;


procedure T2DEngine.SetZOrder();
var i: Integer; Done: Boolean;
begin
  Done := False;
  repeat
    for i := List.Count - 1 downto 0 do
    begin
     if i = 0 then
      begin
        Done := True;
        break;
      end;
      if TRaySprite(List.Items[i]).Z < TRaySprite(List.Items[i - 1]).Z then
      begin
        List.Move(i, i - 1);
        break;
      end;
    end;
  until Done;
end;

constructor T2DEngine.Create;
begin
  List := TList.Create;
  DeadList := TList.Create;
  FCamera.target.x:=0;
end;

destructor T2DEngine.Destroy;
var i: Integer;
begin
  for i := 0 to List.Count - 1 do  TRaySprite(List.Items[i]).Destroy;
  List.Destroy;
  DeadList.Destroy;
  inherited Destroy;
end;

end.


