unit ray_sprite;

{$mode objfpc}{$H+}
{$WARN 5027 off : Local variable "$1" is assigned but never used}
{$WARN 5024 off : Parameter "$1" not used}
interface

uses ray_header, ray_math, ray_math_ex, Classes, SysUtils;

type
  TJumpState = (jsNone, jsJumping, jsFalling);
  TFlipState = (fsNormal, fsX, fsY, fsXY);
  TCollideMethod = (cmRectangle, cmCircle, cmPointRec, cmPointCircle, cmPolygon);

  { TRaySpriteEngine }
  TRaySpriteEngine = class
  private
    FWorld: TVector2;
    FDeadList: TList;
    FList: TList;
    procedure SetWorldX(Value: single);
    procedure SetWorldY(Value: single);
  public
    procedure Draw();
    procedure ClearDeadSprites;
    procedure Move(MoveCount: double);
    procedure SetZOrder();
    constructor Create;
    destructor Destroy; override;
    property WorldX: single read FWorld.X write SetWorldX;
    property WorldY: single read FWorld.Y write SetWorldY;
  end;

  TPattern = record
    Height, Width: integer;
  end;

  { TRayGameTexture }
  TRayGameTexture = class
  public
    Count: integer;
    TextureName: array of string;
    Texture: array of TTexture2D;
    Pattern: array of TPattern;
    function LoadFromFile(FileName: string; Width, Height: integer): boolean;
    constructor Create;
    destructor Destroy; override;
  end;

  { TRaySprite }
  TRaySprite = class
  private
    FAnimated: boolean;
    FCollideMethod: TCollideMethod;
    FCollidePolygon: TRayPolygon;
    FCollidePos: TVector2;
    FCollideRadius: single;
    FCollideRect: TRectangle;
    FCollisioned: boolean;
    FShowCollide: boolean;
    FPositionV: TVector2;
    FZ: single;
    FScale: single;
  protected
    FEngine: TRaySpriteEngine;
    FTextureName: string;
    FTextureIndex: integer;
    procedure SetTextureName(Value: string);
    procedure SetTextureIndex(Value: integer);
    procedure DoCollision(const Sprite: TRaySprite); virtual;
  public
    FTexture: TRayGameTexture;
    FlipState: TFlipState;
    Alpha: byte;
    Angle: single;
    IsSpriteDead: boolean;
    DrawMode: integer;
    Visible: boolean;
    Pattern: TNPatchInfo;
    procedure Draw();
    procedure Move(MoveCount: double); virtual;
    procedure Dead();
    procedure SetOrder(Value: single);
    procedure SetScale(Value: single);
    procedure Collision(const Other: TRaySprite); overload; virtual;
    procedure Collision; overload; virtual;
    constructor Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture); virtual;
    destructor Destroy; override;
    property TextureIndex: integer read FTextureIndex write SetTextureIndex;
    property TextureName: string read FTextureName write SetTextureName;
    property X: single read FPositionV.X write FPositionV.X;
    property Y: single read FPositionV.Y write FPositionV.Y;
    property Z: single read FZ write SetOrder;
    property Scale: single read FScale write SetScale;
    property Collisioned: boolean read FCollisioned write FCollisioned;
    property CollideMethod: TCollideMethod read FCollideMethod write FCollideMethod;
    property CollidePos: TVector2 read FCollidePos write FCollidePos;
    property CollideRect: TRectangle read FCollideRect write FCollideRect;
    property CollideRadius: single read FCollideRadius write FCollideRadius;
    property CollidePolygon: TRayPolygon read FCollidePolygon write FCollidePolygon;
    property ShowCollide: boolean read FShowCollide write FShowCollide;
  end;

  { TRayAnimatedSprite }
  TRayAnimatedSprite = class(TRaySprite)
  protected
    FDoAnimated: boolean;
    FPatternIndex: integer;
    FPatternHeight: integer;
    FPatternWidth: integer;
    procedure SetPatternHeight(Value: integer);
    procedure SetPatternWidth(Value: integer);
  public
    AnimLooped: boolean;
    AnimStart: integer;
    AnimCount: integer;
    AnimSpeed: single;
    AnimPos: single;
    procedure Draw();
    procedure Move(MoveCount: double); override;
    procedure DoAnim(Looped: boolean; Start: integer; Count: integer; Speed: single);
    constructor Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture); override;
    destructor Destroy; override;
    property PatternHeight: integer read FPatternHeight write SetPatternHeight;
    property PatternWidth: integer read FPatternWidth write SetPatternWidth;
  end;

  { TPlayerSprite }
  TPlayerSprite = class(TRayAnimatedSprite)
  private
    FSpeed: single;
    FAcc: single;
    FDcc: single;
    FMinSpeed: single;
    FMaxSpeed: single;
    FVelocityX: single;
    FVelocityY: single;
    FDirection: integer;
    procedure SetSpeed(Value: single);
    procedure SetDirection(Value: integer);
  public
    constructor Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture);override;
    procedure UpdatePos;
    procedure FlipXDirection;
    procedure FlipYDirection;
    procedure Accelerate; virtual;
    procedure Deccelerate; virtual;
    procedure Stop; virtual; abstract;
    procedure Resume; virtual; abstract;
    procedure Update; virtual; abstract;
    property Speed: single read FSpeed write SetSpeed;
    property MinSpeed: single read FMinSpeed write FMinSpeed;
    property MaxSpeed: single read FMaxSpeed write FMaxSpeed;
    property VelocityX: single read FVelocityX write FVelocityX;
    property VelocityY: single read FVelocityY write FVelocityY;
    property Acceleration: single read FAcc write FAcc;
    property Decceleration: single read FDcc write FDcc;
    property Direction: integer read FDirection write SetDirection;
  end;

  { TJumperSprite }
  TJumperSprite = class(TPlayerSprite)
  private
    FJumpCount: integer;
    FJumpSpeed: single;
    FJumpHeight: single;
    FMaxFallSpeed: single;
    FDoJump: boolean;
    FJumpState: TJumpState;
    procedure SetJumpState(Value: TJumpState);
  public
    constructor Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture);override;
    procedure Move(MoveCount: double); override;
    procedure Accelerate; override;
    procedure Deccelerate; override;
    property JumpCount: integer read FJumpCount write FJumpCount;
    property JumpState: TJumpState read FJumpState write SetJumpState;
    property JumpSpeed: single read FJumpSpeed write FJumpSpeed;
    property JumpHeight: single read FJumpHeight write FJumpHeight;
    property MaxFallSpeed: single read FMaxFallSpeed write FMaxFallSpeed;
    property DoJump: boolean read FDoJump write FDoJump;
  end;

const
  ModuleName = 'RAY_SPRITES: ';

implementation

{ TJumperSprite }
procedure TJumperSprite.SetJumpState(Value: TJumpState);
begin
  if FJumpState <> Value then
  begin
    FJumpState := Value;
    case Value of
      jsNone,
      jsFalling:
      begin
        FVelocityY := 0;
      end;
    end;
  end;
end;

constructor TJumperSprite.Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture);
begin
  inherited Create(Engine, Texture);
  FVelocityX := 0;
  FVelocityY := 0;
  MaxSpeed := FMaxSpeed;
  FDirection := 0;
  FJumpState := jsNone;
  FJumpSpeed := 0.25;
  FJumpHeight := 10;
  Acceleration := 0.2;
  Decceleration := 0.2;
  FMaxFallSpeed := 5;
  DoJump := False;
end;

procedure TJumperSprite.Move(MoveCount: double);
begin
  inherited Move(MoveCount);

  case FJumpState of
  jsNone:
    begin
      if DoJump then
      begin
        FJumpState := jsJumping;
        VelocityY := -FJumpHeight;
      end;
    end;

  jsJumping:
    begin
      Y := Y + FVelocityY;
      VelocityY := FVelocityY + FJumpSpeed;
      if VelocityY > 0 then
        FJumpState := jsFalling;
    end;

  jsFalling:
    begin
      Y := Y - FVelocityY;
      VelocityY := VelocityY - FJumpSpeed;
      if VelocityY > FMaxFallSpeed then
        VelocityY := FMaxFallSpeed;
    end;

  end;

  DoJump := False;
end;

procedure TJumperSprite.Accelerate;
begin
  if FSpeed <> FMaxSpeed then
  begin
    FSpeed := FSpeed + FAcc;
    if FSpeed > FMaxSpeed then FSpeed := FMaxSpeed;
    VelocityX := Cos256(FDirection) * Speed;
  end;
end;

procedure TJumperSprite.Deccelerate;
begin
  if FSpeed <> FMaxSpeed then
  begin
    FSpeed := FSpeed + FAcc;
    if FSpeed < FMaxSpeed then FSpeed := FMaxSpeed;
    VelocityX := Cos256(FDirection) * Speed;
  end;
end;

{ TPlayerSprite }

procedure TPlayerSprite.SetSpeed(Value: single);
begin
  if FSpeed > FMaxSpeed then
    FSpeed := FMaxSpeed
  else
  if FSpeed < FMinSpeed then
    FSpeed := FMinSpeed;
  FSpeed := Value;
  VelocityX := Cos256(FDirection) * Speed;
  VelocityY := Sin256(FDirection) * Speed;
end;

procedure TPlayerSprite.SetDirection(Value: integer);
begin
  FDirection := Value;
  VelocityX := Cos256(FDirection) * Speed;
  VelocityY := Sin256(FDirection) * Speed;
end;

constructor TPlayerSprite.Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture);
begin
  inherited Create(Engine, Texture);
  FVelocityX := 0;
  FVelocityY := 0;
  Acceleration := 0;
  Decceleration := 0;
  Speed := 0;
  MinSpeed := 0;
  MaxSpeed := 0;
  FDirection := 0;
end;

procedure TPlayerSprite.UpdatePos;
begin
  X := X + VelocityX;
  Y := Y + VelocityY;
end;

procedure TPlayerSprite.FlipXDirection;
begin
  if FDirection >= 64 then
    FDirection := 192 + (64 - FDirection)
  else
  if FDirection > 0 then
    FDirection := 256 - FDirection;
end;

procedure TPlayerSprite.FlipYDirection;
begin
  if FDirection > 128 then
    FDirection := 128 + (256 - FDirection)
  else
    FDirection := 128 - FDirection;
end;

procedure TPlayerSprite.Accelerate;
begin
  if FSpeed <> FMaxSpeed then
  begin
    FSpeed := FSpeed + FAcc;
    if FSpeed > FMaxSpeed then FSpeed := FMaxSpeed;
    VelocityX := Cos256(FDirection) * Speed;
    VelocityY := Sin256(FDirection) * Speed;
  end;
end;

procedure TPlayerSprite.Deccelerate;
begin
  if FSpeed <> FMinSpeed then
  begin
    FSpeed := FSpeed - FAcc;
    if FSpeed < FMaxSpeed then
      FSpeed := FMinSpeed;
    VelocityX := Cos256(FDirection) * Speed;
    VelocityY := Sin256(FDirection) * Speed;
  end;
end;

{ TRayAnimatedSprite }
procedure TRayAnimatedSprite.SetPatternHeight(Value: integer);
begin
  FPatternHeight := Value;
  Pattern.Bottom := Value;
end;

procedure TRayAnimatedSprite.SetPatternWidth(Value: integer);
begin
  FPatternWidth := Value;
  Pattern.Right := Value;
end;

procedure TRayAnimatedSprite.Draw();
var
  FramesPerLine, NumLines, i: integer;
  Position: TVector2;
  frameRec, Dest: TRectangle;
  AlphaColor: TColor;
begin
  FramesPerLine := Ftexture.Texture[FTextureIndex].Width div
    FTexture.Pattern[FTextureIndex].Width;
  //Ширина прямоугольника спрайта в один кадр
  NumLines := Ftexture.Texture[FTextureIndex].Height div
    FTexture.Pattern[FTextureIndex].Height;
  //Высота прямоугольника одного кадра спрайта

  if (TextureIndex <> -1) and (Assigned(FEngine)) then
  begin
    if Visible then
    begin
      if FShowCollide then
        //DrawCollide
        case FCollideMethod of
          cmRectangle:
            DrawRectangleRec(Self.CollideRect, RED);
          cmCircle:
            DrawCircleV(Self.CollidePos, Self.CollideRadius, RED);
          cmPolygon:
            for i := 0 to Length(FCollidePolygon) - 1 do
              DrawPixelV(FCollidePolygon[i], RED);
        end;

      case FlipState of
        fsNormal:
          RectangleSet(@frameRec, X, Y, FTexture.Pattern[FTextureIndex].Width,
            FTexture.Pattern[FTextureIndex].Height);
        fsX:
          RectangleSet(@frameRec, X, Y, -FTexture.Pattern[FTextureIndex].Width,
            FTexture.Pattern[FTextureIndex].Height);
        fsY:
          RectangleSet(@frameRec, X, Y, FTexture.Pattern[FTextureIndex].Width,
            -FTexture.Pattern[FTextureIndex].Height);
        fsXY:
          RectangleSet(@frameRec, X, Y, -FTexture.Pattern[FTextureIndex].Width,
            -FTexture.Pattern[FTextureIndex].Height);
      end;

      frameRec.x := Trunc(AnimPos) * Ftexture.Texture[FTextureIndex].Width /
        FramesPerLine;
      frameRec.y := FTexture.Pattern[FTextureIndex].Height * Trunc(
        AnimPos / NumLines);

      RectangleSet(@Dest, X, Y, FTexture.Pattern[FTextureIndex].Width * Scale,
        FTexture.Pattern[FTextureIndex].Height * Scale);

      AlphaColor := White;
      AlphaColor.a := Alpha;
      Vector2Set(@Position, 0, 0);

      DrawTexturePro(FTexture.Texture[FTextureIndex], frameRec,
        Dest, position, Angle, AlphaColor);
    end;
  end;
end;

procedure TRayAnimatedSprite.Move(MoveCount: double);
begin
  if AnimSpeed > 0 then
  begin
    AnimPos := AnimPos + AnimSpeed * MoveCount;
    FPatternIndex := Round(AnimPos);

    if (Round(AnimPos) > AnimStart + AnimCount) then
    begin
      if (Round(AnimPos)) = AnimStart + AnimCount then
        if AnimLooped then
        begin
          AnimPos := AnimStart;
          FPatternIndex := Round(AnimPos);
        end
        else
        begin
          AnimPos := AnimStart + AnimCount - 1;
          FPatternIndex := Round(AnimPos);
        end;
    end;

    if FDoAnimated = True then
    begin
      if Round(AnimPos) >= AnimCount + 1 then
      begin
        FDoAnimated := False;
        AnimLooped := False;
        AnimSpeed := 0;
        AnimCount := 0;
        AnimPos := AnimStart;
        FPatternIndex := Round(AnimPos);
      end;
    end;

    if Round(AnimPos) < AnimStart then
    begin
      AnimPos := AnimStart;
      FPatternIndex := Round(AnimPos);
    end;

    if Round(AnimPos) > AnimCount then
    begin
      AnimPos := AnimStart;
      FPatternIndex := Trunc(AnimPos);
    end;
  end;
end;

procedure TRayAnimatedSprite.DoAnim(Looped: boolean; Start: integer;
  Count: integer; Speed: single);
begin
  FDoAnimated := True;
  AnimLooped := Looped;
  AnimStart := Start;
  AnimCount := Count;
  AnimSpeed := Speed;
end;

constructor TRayAnimatedSprite.Create(Engine: TRaySpriteEngine;
  Texture: TRayGameTexture);
begin
  inherited Create(Engine, Texture);
  FAnimated := True;
  FlipState := fsNormal;
end;

destructor TRayAnimatedSprite.Destroy;
begin
  inherited Destroy;
end;

{ TRaySprite }
procedure TRaySprite.SetTextureName(Value: string);
var
  i: integer;
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

procedure TRaySprite.SetTextureIndex(Value: integer);
begin
  FTextureIndex := Value;
  if high(FTexture.Pattern) >= 0 then
  begin
    Pattern.Right := FTexture.Pattern[FTextureIndex].Height;
    Pattern.Bottom := FTexture.Pattern[FTextureIndex].Width;
  end
  else
    TraceLog(LOG_ERROR, PChar(ModuleName + 'The texture index(' +
      IntToStr(Value) + ') does not exist'));
end;

procedure TRaySprite.DoCollision(const Sprite: TRaySprite);
begin

end;

procedure TRaySprite.Draw();
var
  Source: TRectangle;
  Dest: TRectangle;
  WH: TVector2;
  AlphaColor: TColor;
  i: integer;
begin
  if TextureIndex <> -1 then
  begin
    if Assigned(FEngine) then
    begin
      if Visible then
      begin
        if FShowCollide then

          case FCollideMethod of
            cmRectangle: DrawRectangleRec(Self.CollideRect, RED);
            cmCircle: DrawCircleV(Self.CollidePos, Self.CollideRadius, RED);
            cmPolygon:
              for i := 0 to Length(FCollidePolygon) - 1 do
                DrawPixelV(FCollidePolygon[i], RED);
          end;

        case FlipState of
          fsNormal:
            RectangleSet(@Source, 0, 0, FTexture.Pattern[FTextureIndex].Width,
              FTexture.Pattern[FTextureIndex].Height);
          fsX:
            RectangleSet(@Source, 0, 0, -FTexture.Pattern[FTextureIndex].Width,
              FTexture.Pattern[FTextureIndex].Height);
          fsY:
            RectangleSet(@Source, 0, 0, FTexture.Pattern[FTextureIndex].Width,
              -FTexture.Pattern[FTextureIndex].Height);
          fsXY:
            RectangleSet(@Source, 0, 0, -FTexture.Pattern[FTextureIndex].Width,
              -FTexture.Pattern[FTextureIndex].Height);
        end;

        RectangleSet(@Dest, X, Y,
          FTexture.Pattern[FTextureIndex].Width * Scale,
          FTexture.Pattern[FTextureIndex].Height * Scale);

        WH := Vector2Create(0, 0);
        AlphaColor := White;
        AlphaColor.a := alpha;

        DrawTexturePro(FTexture.Texture[FTextureIndex], Source, Dest,
          WH, Angle, AlphaColor);
      end;
    end;
  end;
end;

procedure TRaySprite.Move(MoveCount: double);
begin

end;

procedure TRaySprite.Dead();
begin
  if IsSpriteDead = False then
  begin
    IsSpriteDead := True;
    FEngine.FDeadList.Add(Self);
    Self.Visible := False;
  end;
end;

procedure TRaySprite.SetOrder(Value: single);
begin
  if FZ <> Value then FZ := Value;
  FEngine.SetZOrder;
end;

procedure TRaySprite.SetScale(Value: single);
begin
  FScale := Value;
end;

procedure TRaySprite.Collision(const Other: TRaySprite);
var
  IsCollide: boolean;
begin
  IsCollide := False;
  if (FCollisioned) and (Other.FCollisioned) and (not IsSpriteDead) and
    (not Other.IsSpriteDead) then
  begin
    case FCollideMethod of
      cmRectangle: IsCollide := CheckCollisionRecs(Self.CollideRect, Other.CollideRect);
      cmCircle: IsCollide := CheckCollisionCircles(
          Self.CollidePos, Self.CollideRadius, Other.CollidePos, Other.CollideRadius);
      cmPointRec: IsCollide := CheckCollisionPointRec(Self.CollidePos, Other.CollideRect);
      cmPointCircle: IsCollide :=
          CheckCollisionPointCircle(Self.CollidePos, Other.CollidePos, Other.CollideRadius);
      cmPolygon: IsCollide := OverlapPolygon(Self.CollidePolygon, Other.CollidePolygon);
    end;
    if IsCollide then
    begin
      DoCollision(Other);
      Other.DoCollision(Self);
    end;
  end;
end;

procedure TRaySprite.Collision;
var
  i: integer;
begin
  if (FEngine <> nil) and (not IsSpriteDead) and (Collisioned) then
  begin
    for i := 0 to FEngine.FList.Count - 1 do
      Self.Collision(TRaySprite(FEngine.FList.Items[i]));
  end;

end;

constructor TRaySprite.Create(Engine: TRaySpriteEngine; Texture: TRayGameTexture);
begin
  if (Assigned(Engine)) and (Assigned(Texture)) then
  begin
    FAnimated := False;
    FEngine := Engine;
    FEngine.FList.Add(Self);
    FTexture := Texture;
    Pattern.Left := 0;
    Pattern.Top := 0;
    Alpha := 255;
    Scale := 1.0;
    Visible := True;
    TraceLog(LOG_INFO, ModuleName + 'Sprite engine created successfully');
  end
  else
  begin
    TraceLog(LOG_ERROR, ModuleName + 'No SpriteEngine or Game Texture was created.');
  end;
end;

destructor TRaySprite.Destroy;
begin
  inherited Destroy;
end;

{ TRayGameTexture }
function TRayGameTexture.LoadFromFile(FileName: string; Width, Height: integer): boolean;
begin
  if not fileexists(PChar(FileName)) then
  begin
    Result := False;
    TraceLog(LOG_ERROR, PChar(ModuleName + 'File ' + FileName + ' no exits.'));
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
  Result := True;
end;

constructor TRayGameTexture.Create;
begin
  TraceLog(LOG_INFO, ModuleName + 'Game texture created successfully');
end;

destructor TRayGameTexture.Destroy;
var
  i: integer;
begin
  for i := 0 to Count - 1 do
  begin
    TextureName[i] := '';
    Pattern[i].Height := 0;
    Pattern[i].Width := 0;
    UnloadTexture(Texture[i]);
    TraceLog(LOG_INFO, ModuleName + 'Unload texture');
  end;
  SetLength(TextureName, 0);
  SetLength(Texture, 0);
  SetLength(Pattern, 0);
  Count := 0;
  TraceLog(LOG_INFO, ModuleName + 'Game texture destroy');
  inherited Destroy;
end;

procedure TRaySpriteEngine.SetWorldX(Value: single);
begin
  FWorld.X := Value;
end;

procedure TRaySpriteEngine.SetWorldY(Value: single);
begin
  FWorld.Y := Value;
end;

procedure TRaySpriteEngine.Draw();
var
  i: integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if TRaySprite(FList.Items[i]).FAnimated = False then TRaySprite(FList.Items[i]).Draw
    else
      TRayAnimatedSprite(FList.Items[i]).Draw;
  end;
end;

procedure TRaySpriteEngine.ClearDeadSprites;
var
  i: integer;
begin
  for i := 0 to FDeadList.Count - 1 do
  begin
    if FDeadList.Count >= 1 then
    begin
      if TRaySprite(FDeadList.Items[i]).IsSpriteDead = True then
      begin
        TRaySprite(FDeadList.Items[i]).FEngine.FList.Remove(FDeadList.Items[i]);
      end;
    end;
  end;
  FDeadList.Clear;
end;

procedure TRaySpriteEngine.Move(MoveCount: double);
var
  i: integer;
begin
  for i := 0 to FList.Count - 1 do
  begin
    if TRaySprite(FList.Items[i]).FAnimated = False then
      TRaySprite(FList.Items[i]).Move(MoveCount)
    else
      TRayAnimatedSprite(FList.Items[i]).Move(MoveCount);
  end;
end;

procedure TRaySpriteEngine.SetZOrder();
var
  i: integer;
  Done: boolean;
begin
  Done := False;
  repeat
    for i := FList.Count - 1 downto 0 do
    begin
      if i = 0 then
      begin
        Done := True;
        break;
      end;
      if TRaySprite(FList.Items[i]).Z < TRaySprite(FList.Items[i - 1]).Z then
      begin
        FList.Move(i, i - 1);
        break;
      end;
    end;
  until Done;
end;

constructor TRaySpriteEngine.Create;
begin
  FList := TList.Create;
  FDeadList := TList.Create;
end;

destructor TRaySpriteEngine.Destroy;
var
  i: integer;
begin
  for i := 0 to FList.Count - 1 do TRaySprite(FList.Items[i]).Destroy;
  FList.Destroy;
  FDeadList.Destroy;
  inherited Destroy;
end;

end.
