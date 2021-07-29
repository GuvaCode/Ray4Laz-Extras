unit ray_sprite_engine;

{$mode ObjFPC}{$H+}

interface

uses
  cmem, ray_header, fgl, Generics.Collections,
  TypesEx, Math, Classes, SysUtils;

type
  TBlendingEffect = ( Undefined = -1, Alpha, Additive, Multiplied, AddColors,
  Subtract, Custom);

  TCollideMode = (cmCircle, cmRect, cmQuadrangle, cmPolygon);

  TAnimPlayMode = (pmForward, pmBackward, pmPingPong);

  TJumpState = (jsNone, jsJumping, jsFalling);

  TImageType = (itSingleImage, itSpriteSheet);

  TMirrorMode = (MirrorNormal , MirrorX , MirrorY , MirrorXY);

  TFrameRec = record
    FrameName: string;
    Frames: array of Cardinal;
  end;

  { ESpriteError }
  ESpriteError = class(Exception);

  TSpriteEngine = class;
  TSpriteClass = class of TSprite;

  { TAnimations }
  TAnimations = class
  private
    FrameData: array of TFrameRec;
    SearchObjects: array of Integer;
    SearchDirty: Boolean;
    function GetItem(Index: Integer): TFrameRec;
    function GetItemCount(): Integer;

    procedure InitSearchObjects();
    procedure SwapSearchObjects(Index1, Index2: Integer);
    function CompareSearchObjects(Obj1, Obj2: TFrameRec): Integer;
    function SplitSearchObjects(Start, Stop: Integer): Integer;
    procedure SortSearchObjects(Start, Stop: Integer);
    procedure UpdateSearchObjects();
    function GetFrame(const Name: string): TFrameRec;
  public
    property Items[Index: Integer]: TFrameRec read GetItem; Default;
    property ItemCount: Integer read GetItemCount;
    property Frame[const Name: string]: TFrameRec read GetFrame;
    function IndexOf(const Name: string): Integer; overload;
    procedure Remove(Index: Integer);
    procedure AddFrames(FrameName: string; Frames: array of Cardinal); overload;
    procedure RemoveAll();
    procedure MarkSearchDirty();
    constructor Create();
    destructor Destroy(); override;
  end;

  { TSprite }
  TSprite = class
  private
    FEngine: TSpriteEngine;
    FImageLib: specialize TDictionary<string, TTexture>;
    FList: specialize TList<TSprite>;
    FDrawList: specialize TList<TSprite>;
    FParent: TSprite;
    FDeaded: Boolean;
    FWidth: Integer;
    FHeight: Integer;
    FName: string;
    FX, FY: Single;
    FZ: Integer;
    FWorldX, FWorldY: Single;
    FVisible: Boolean;
    FBlendingEffect: TBlendingEffect;
    FDoCollision: Boolean;
    FCollisioned: Boolean;
    FImageName: string;
    FImageIndex: Integer;
    FMoved: Boolean;
    FTruncMove: Boolean;
    FCollidePos: TPoint;
    FCollideRadius: Integer;
    FCollideRect: TRect;
    FTag: Integer;
    FCollideQuadrangle: TPoint4;
    FCollidePolygon: TPolygon;
    FCollideMode: TCollideMode;
    FZSet: Boolean;
    procedure Add(Sprite: TSprite);
    procedure Remove(Sprite: TSprite);
    procedure AddDrawList(Sprite: TSprite);
    procedure Draw; virtual;
    function GetCount: Integer;
    function GetItem(Index: Integer): TSprite;
    function GetImageWidth: Integer;
    function GetImageHeight: Integer;
  protected
    procedure DoDraw; virtual;
    procedure DoMove(const MoveCount: Single); virtual;
    procedure DoCollision(const Sprite: TSprite); virtual;
    procedure SetName(const Value: string); virtual;
    procedure SetImageName(const Value: string); virtual;
    procedure SetX(const Value: Single); virtual;
    procedure SetY(const Value: Single); virtual;
    procedure SetZ(const Value: Integer); virtual;
  public
    constructor Create(const AParent: TSprite); virtual;
    destructor Destroy; override;
    procedure Assign(const Value: TSprite); virtual;
    procedure Clear;
    procedure Move(const MoveCount: Single);
    procedure SetPos(X, Y: Single); overload;
    procedure SetPos(X, Y: Single; Z: Integer); overload;
    procedure Collision(const Other: TSprite); overload; virtual;
    procedure Collision; overload; virtual;
    procedure Dead;
    property Visible: Boolean read FVisible write FVisible;
    property X: Single read FX write SetX;
    property Y: Single read FY write SetY;
    property Z: Integer read FZ write SetZ;
    property ImageName: string read FImageName write FImageName;
    property ImageLib: specialize TDictionary<string, TTexture> read FImageLib write FImageLib;
    property ImageIndex: Integer read FImageIndex write FImageIndex;
    property ImageWidth: Integer read GetImageWidth;
    property ImageHeight: Integer read GetImageHeight;
    property Width: Integer read FWidth write FWidth;
    property Height: Integer read FHeight write FHeight;
    property WorldX: Single read FWorldX write FWorldX;
    property WorldY: Single read FWorldY write FWorldY;
    property BlendingEffect: TBlendingEffect read FBlendingEffect write FBlendingEffect;
    property Name: string read FName write SetName;
    property Moved: Boolean read FMoved write FMoved;
    property TruncMove: Boolean read FTruncMove write FTruncMove;
    property CollidePos: TPoint read FCollidePos write FCollidePos;
    property CollideRadius: Integer read FCollideRadius write FCollideRadius;
    property CollideRect: TRect read FCollideRect write FCollideRect;
    property CollideQuadrangle: TPoint4 read FCollideQuadrangle write FCollideQuadrangle;
    property CollidePolygon: TPolygon read FCollidePolygon write FCollidePolygon;
    property CollideMode: TCollideMode read FCollideMode write FCollideMode;
    property Collisioned: Boolean read FCollisioned write FCollisioned;
    property Items[Index: Integer]: TSprite read GetItem; Default;
    property SpriteList: specialize TList<TSprite> read FList write FList;
    property Count: Integer read GetCount;
    property Engine: TSpriteEngine read FEngine write FEngine;
    property Parent: TSprite read FParent;
    property Tag: Integer read FTag write FTag;
  end;

  { TSpriteEx }
  TSpriteEx = class(TSprite)
  private
    FMirrorMode: TMirrorMode;
    FX1, FY1, FX2, FY2, FX3, FY3, FX4, FY4: Single;

    FCenterX, FCenterY: Single;
    FDoCenter: Boolean;
    FColor1, FColor2, FColor3, FColor4: Cardinal;
    FRed, FGreen, FBlue: Integer;
    FAlpha: Integer;
    FAngle: Single;
    FAngle360: Integer;
    FSrcAngle, FDestAngle: Single;
    FScaleX, FScaleY: Single;
    FImageType: TImageType;
    FSelected: Boolean;
    FGroupNumber: Integer;
    FMouseEnterFlag: Boolean;
    FMouseDownFlag: Boolean;
    FActiveRect: TRect;
    FSpeedX, FSpeedY: Single;
    FPositionListX, FPositionListY: TList;
    FAttachTo: TSprite;
    FCanCollision: Boolean;
  protected
    procedure SetRed(const Value: Integer); virtual;
    procedure SetGreen(const Value: Integer); virtual;
    procedure SetBlue(const Value: Integer); virtual;
    procedure SetAlpha(const Value: Integer); virtual;
    procedure SetAngle360(Value: Integer);
    procedure SetGroupNumber(AGroupNumber: Integer); virtual;
    procedure SetSelected(ASelected: Boolean); virtual;
    function GetBoundsRect: TRect; virtual;
  public
    Offset: TPoint;
    constructor Create(const AParent: TSprite); override;
    destructor Destroy; override;
    procedure Assign(const Value: TSprite); override;
    procedure DoDraw; override;
    procedure Draw; override;
    procedure SetColor(const Color: Cardinal); overload;
    procedure SetColor(Red, Green, Blue: Cardinal; Alpha: Cardinal = 255); overload;
    procedure LookAt(TargetX, TargetY: Integer);
    procedure TowardToAngle(Angle: Integer; Speed: Single; DoLookAt: Boolean);
    procedure TowardToPos(TargetX, TargetY: Integer; Speed: Single; DoLookAt: Boolean);
    procedure RotateToAngle(Angle: Integer; RotateSpeed, MoveSpeed: Single);
    procedure RotateToPos(DestX, DestY: Integer; RotateSpeed, MoveSpeed: Single);
    procedure CircleToAngle(Angle, LookAtX, LookAtY: Integer; RotateSpeed, MoveSpeed: Single;
      DoLookAt: Boolean);
    procedure CircleToPos(DestX, DestY, LookAtX, LookAtY: Integer; RotateSpeed, MoveSpeed: Single;
      DoLookAt: Boolean);
    procedure Attach(Sprite: TSprite); virtual;
    procedure Detach;
    function GetSpriteAt(XX, YY: Integer): TSprite;
    function GetDistance(Sprite1, Sprite2: TSprite): Real;
    function MouseInRect: Boolean;
    function SpriteInRect1(InArea: TRect): Boolean;
    function SpriteInRect2(InArea: TRect): Boolean;
    procedure DoMouseEvent;
    procedure OnMouseEnter; virtual;
    procedure OnMouseLeave; virtual;
    procedure OnMouseMove; virtual;
    procedure OnLMouseDown; virtual;
    procedure OnLMouseUp; virtual;
    procedure OnRMouseDown; virtual;
    procedure OnRMouseUp; virtual;
    procedure OnMouseDbClick; virtual;
    procedure OnMouseWheelUp; virtual;
    procedure OnMouseWheelDown; virtual;
    procedure OnMouseDrag; virtual;
    property ActiveRect: TRect read FActiveRect write FActiveRect;
    // for mouse event
    property X1: Single read FX1 write FX1;
    property Y1: Single read FY1 write FY1;
    property X2: Single read FX2 write FX2;
    property Y2: Single read FY2 write FY2;
    property X3: Single read FX3 write FX3;
    property Y3: Single read FY3 write FY3;
    property X4: Single read FX4 write FX4;
    property Y4: Single read FY4 write FY4;
    property Red: Integer read FRed write SetRed default 255;
    property Green: Integer read FGreen write SetGreen default 255;
    property Blue: Integer read FBlue write SetBlue default 255;
    property Alpha: Integer read FAlpha write SetAlpha default 255;
    property Color1: Cardinal read FColor1 write FColor1;
    property Color2: Cardinal read FColor2 write FColor2;
    property Color3: Cardinal read FColor3 write FColor3;
    property Color4: Cardinal read FColor4 write FColor4;
    property Angle: Single read FAngle write FAngle;
    property Angle360: Integer read FAngle360 write SetAngle360;
    property CenterX: Single read FCenterX write FCenterX;
    property CenterY: Single read FCenterY write FCenterY;
    property ScaleX: Single read FScaleX write FScaleX;
    property ScaleY: Single read FScaleY write FScaleY;
    property DoCenter: Boolean read FDoCenter write FDoCenter;
    property SpeedX: Single read FSpeedX write FSpeedX;
    property SpeedY: Single read FSpeedY write FSpeedY;
    property ImageType: TImageType read FImageType write FImageType;
    property MirrorMode: TMirrorMode read FMirrorMode write FMirrorMode;
    property BoundsRect: TRect read GetBoundsRect;
    property GroupNumber: Integer read FGroupNumber write SetGroupNumber;
    property Selected: Boolean read FSelected write SetSelected;
    property CanCollision: Boolean read FCanCollision write FCanCollision;
  end;

  { TAnimatedSprite }

  TAnimatedSprite = class(TSpriteEx)
  private
    FDoAnimate: Boolean;
    FAnimLooped: Boolean;
    FAnimStart: Integer;
    FAnimCount: Integer;
    FAnimSpeed: Single;
    FAnimPos: Single;
    FAnimEnded: Boolean;
    FDoFlag1, FDoFlag2: Boolean;
    FAnimPlayMode: TAnimPlayMode;
    FPatternIndex: Integer;
    FPatternWidth: Integer;
    FPatternHeight: Integer;
    FPatternCount: Integer;
    procedure SetAnimStart(Value: Integer);
  public
    constructor Create(const AParent: TSprite); override;
    procedure Assign(const Value: TSprite); override;
    procedure DoDraw; override;
    procedure DoMove(const MoveCount: Single); override;
    function AnimEnded: Boolean;
    procedure SetAnim(AniImageName: string; AniStart, AniCount: Integer; AniSpeed: Single; AniLooped,
       DoAnimate: Boolean; AniMirrorMode :TMirrorMode;  PlayMode: TAnimPlayMode = pmForward); overload; virtual;
    procedure SetAnim(AniImageName: string; AniStart, AniCount: Integer; AniSpeed: Single; AniLooped:
      Boolean; PlayMode: TAnimPlayMode = pmForward); overload; virtual;
    procedure OnAnimStart; virtual;
    procedure OnAnimEnd; virtual;
    procedure SetPatternIndex(const Value: Integer);
    procedure SetPattern(APatternWidth, APatternHeight: Integer);
    property PatternIndex: Integer read FPatternIndex write SetPatternIndex;
    property PatternWidth: Integer read FPatternWidth write FPatternWidth;
    property PatternHeight: Integer read FPatternHeight write FPatternHeight;
    property PatternCount: Integer read FPatternCount write FPatternCount;
    property AnimPos: Single read FAnimPos write FAnimPos;
    property AnimStart: Integer read FAnimStart write SetAnimStart;
    property AnimCount: Integer read FAnimCount write FAnimCount;
    property AnimSpeed: Single read FAnimSpeed write FAnimSpeed;
    property AnimLooped: Boolean read FAnimLooped write FAnimLooped;
    property DoAnimate: Boolean read FDoAnimate write FDoAnimate;
    property AnimPlayMode: TAnimPlayMode read FAnimPlayMode write FAnimPlayMode;
  end;

  { TSpriteEngine }
  TSpriteEngine = class(TSprite)
   private
     FAllCount: Integer;
     FDeadList: TList;
     FDrawCount: Integer;
     FObjectsSelected: Boolean;
     FGroupCount: Integer;
     FGroups: array of TList;
     FCurrentSelected: TList;
     FVisibleWidth: Integer;
     FVisibleHeight: Integer;
     FDoMouseEvent: Boolean;
     FZCounter: Integer;
   protected
     procedure SetGroupCount(AGroupCount: Integer); virtual;
     function GetGroup(Index: Integer): TList; virtual;
   public
     constructor Create(const AParent: TSprite); override;
     destructor Destroy; override;
     procedure Draw; override;
     procedure DrawEx(TypeList: array of string);
     procedure Dead;
     function Select(Point: TPoint; Filter: array of TSpriteClass; Add_: Boolean = False): TSprite;overload;
     function Select(Point: TPoint; Add_: Boolean = False): TSprite; overload;
     procedure ClearCurrent;
     procedure ClearGroup(GroupNumber: Integer);
     procedure GroupToCurrent(GroupNumber: Integer; Add_: Boolean = False);
     procedure CurrentToGroup(GroupNumber: Integer; Add_: Boolean = False);
     procedure GroupSelect(const Area: TRect; Filter: array of TSpriteClass; Add_: Boolean = False); overload;
     procedure GroupSelect(const Area: TRect; Add_: Boolean = False); overload;
     property AllCount: Integer read FAllCount;
     property DrawCount: Integer read FDrawCount;
     property VisibleWidth: Integer read FVisibleWidth write FVisibleWidth;
     property VisibleHeight: Integer read FVisibleHeight write FVisibleHeight;
     property WorldX: Single read FWorldX write FWorldX;
     property WorldY: Single read FWorldY write FWorldY;
     property CurrentSelected: TList read FCurrentSelected;
     property ObjectsSelected: Boolean read FObjectsSelected;
     property Groups[index: Integer]: TList read GetGroup;
     property GroupCount: Integer read FGroupCount write SetGroupCount;
   end;

implementation

{ TAnimatedSprite }

procedure TAnimatedSprite.SetAnimStart(Value: Integer);
begin
    if FAnimStart <> Value then
  begin
    FAnimStart := Value;
    FAnimPos := Value;
  end;
end;

function Mod2f(I: Double; i2: Integer): Double;
begin
  if i2 = 0 then
    Result := I
  else
  begin
    Result := I - Trunc(I / i2) * i2;
    if Result < 0 then
      Result := i2 + Result;
  end;
end;

constructor TAnimatedSprite.Create(const AParent: TSprite);
begin
  inherited Create(AParent);
  FDoAnimate := False;
  FAnimLooped := True;
  FAnimStart := 0;
  FAnimCount := 0;
  FAnimSpeed := 0;
  FAnimPos := 0;
  FAnimPlayMode := pmForward;
  FDoFlag1 := False;
  FDoFlag2 := False;
end;

procedure TAnimatedSprite.Assign(const Value: TSprite);
begin
  if (Value is TAnimatedSprite) then
  begin
    DoAnimate := TAnimatedSprite(Value).DoAnimate;
    AnimStart := TAnimatedSprite(Value).AnimStart;
    AnimCount := TAnimatedSprite(Value).AnimCount;
    AnimSpeed := TAnimatedSprite(Value).AnimSpeed;
    AnimLooped := TAnimatedSprite(Value).AnimLooped;
  end;
  inherited Assign(Value);
end;

procedure TAnimatedSprite.DoDraw;
var frameRec, Dest: TRectangle;
    AlphaColor: TColor;
    FramesPerLine, NumLines:integer;
begin
    if not FImageLib.ContainsKey(FImagename) then Exit;

    case MirrorMode of
    mirrorNormal:RectangleSet(@frameRec, 0, 0, Self.PatternWidth, Self.PatternHeight);
    mirrorX:     RectangleSet(@frameRec, 0, 0,-Self.PatternWidth, Self.PatternHeight);
    mirrorY:     RectangleSet(@frameRec, 0, 0, Self.PatternWidth,-Self.PatternHeight);
    mirrorXY:    RectangleSet(@frameRec, 0, 0,-Self.PatternWidth,-Self.PatternHeight);
   end;

    FramesPerLine := FImageLib[FImageName].Width div FPatternWidth; //Ширина прямоугольника спрайта в один кадр
    NumLines := FImageLib[FImageName].Height div FPatternHeight;  //Высота прямоугольника одного кадра спрайта

  //  frameRec.x := (  64 * FPatternIndex) / 3;

    //frameRec.y := FPatternHeight *(AnimPos / NumLines);

    //frameRec.y := FTexture.Pattern[FTextureIndex].Height * Trunc(AnimPos / NumLines);

    RectangleSet(@Dest,
    FX + FWorldX + Offset.X - FEngine.FWorldX,
    FY + FWorldY + Offset.Y - FEngine.FWorldY,
    FPatternWidth * FScaleX, FPatternHeight * FScaleY);

    AlphaColor := White;
      AlphaColor.a := Alpha;
      //(@Position, 0, 0);

      DrawTexturePro( FImageLib[FImageName], frameRec, Dest, Vector2Create(0,0), Angle, AlphaColor);

      {  case TruncMove of
        True:
    {      FEngine.FCanvas.DrawPattern(FImageLib[FImageName], Round(FX + FWorldX + Offset.X - FEngine.FWorldX),
            Round(FY + FWorldY + Offset.Y - FEngine.FWorldY), ScaleX, ScaleY, PatternIndex,
            PatternWidth, PatternHeight, FMirrorX, ARGB(FAlpha, FRed, FGreen, FBlue),
            FBlendingEffect);  }

        False:
        {  FEngine.FCanvas.DrawPattern(FImageLib[FImageName], FX + FWorldX + Offset.X - FEngine.FWorldX,
            FY + FWorldY + Offset.Y - FEngine.FWorldY, ScaleX, ScaleY, PatternIndex, PatternWidth,
            PatternHeight, FMirrorX, ARGB(FAlpha, FRed, FGreen, FBlue), FBlendingEffect); }
      end;    }

end;

procedure TAnimatedSprite.DoMove(const MoveCount: Single);
begin
  if not FDoAnimate then  Exit;
  case FAnimPlayMode of
    pmForward: // 12345 12345  12345
      begin
        FAnimPos := FAnimPos + FAnimSpeed * MoveCount;
        if (FAnimPos >= FAnimStart + FAnimCount) then
        begin
          if (Trunc(FAnimPos)) = FAnimStart then
            OnAnimStart;
          if AnimEnded then
          begin
            OnAnimEnd;
          end;

          if FAnimLooped then
            FAnimPos := FAnimStart
          else
          begin
            FAnimPos := FAnimStart + FAnimCount - 1;
            FDoAnimate := False;
          end;
        end;
        FPatternIndex := Trunc(FAnimPos);
      end;
    pmBackward: // 54321 54321 54321
      begin
        FAnimPos := FAnimPos - FAnimSpeed * MoveCount;
        if (FAnimPos < FAnimStart) then
        begin
          if FAnimLooped then
            FAnimPos := FAnimStart + FAnimCount
          else
          begin
            FAnimPos := FAnimStart + FAnimCount;
            FDoAnimate := False;
          end;
        end;
        FPatternIndex := Trunc(FAnimPos);
        FImageIndex := Trunc(FAnimPos);
      end;
    pmPingPong: // 12345432123454321
      begin
        FAnimPos := FAnimPos + FAnimSpeed * MoveCount;
        if FAnimLooped then
        begin
          if (FAnimPos > FAnimStart + FAnimCount - 1) or (FAnimPos < FAnimStart) then
            FAnimSpeed := -FAnimSpeed;
        end
        else
        begin
          if (FAnimPos > FAnimStart + FAnimCount) or (FAnimPos < FAnimStart) then
            FAnimSpeed := -FAnimSpeed;
          if (Trunc(FAnimPos)) = (FAnimStart + FAnimCount) then
            FDoFlag1 := True;
          if (Trunc(FAnimPos) = FAnimStart) and (FDoFlag1) then
            FDoFlag2 := True;
          if (FDoFlag1) and (FDoFlag2) then
          begin
            FDoAnimate := False;
            FDoFlag1 := False;
            FDoFlag2 := False;
          end;
        end;
        FPatternIndex := Round(FAnimPos);
      end;
  end;
end;

function TAnimatedSprite.AnimEnded: Boolean;
begin
  if Trunc(AnimPos) = (AnimStart + AnimCount - 1) then
    Result := True
  else
    Result := False;
end;

procedure TAnimatedSprite.SetAnim(AniImageName: string; AniStart,
  AniCount: Integer; AniSpeed: Single; AniLooped, DoAnimate: Boolean;
  AniMirrorMode: TMirrorMode; PlayMode: TAnimPlayMode);
begin
  ImageName := AniImageName;
  FAnimStart := AniStart;
  FAnimCount := AniCount;
  FAnimSpeed := AniSpeed;
  FAnimLooped := AniLooped;
  FMirrorMode := AniMirrorMode;
  FDoAnimate := DoAnimate;
  FAnimPlayMode := PlayMode;
  if (FPatternIndex < FAnimStart) or (FPatternIndex >= FAnimCount + FAnimStart) then
  begin
    FPatternIndex := FAnimStart mod FAnimCount;
    FAnimPos := FAnimStart;
  end;
end;

procedure TAnimatedSprite.SetAnim(AniImageName: string; AniStart,
  AniCount: Integer; AniSpeed: Single; AniLooped: Boolean;
  PlayMode: TAnimPlayMode);
begin
  ImageName := AniImageName;
  FAnimStart := AniStart;
  FAnimCount := AniCount;
  FAnimSpeed := AniSpeed;
  FAnimLooped := AniLooped;
  FAnimPlayMode := PlayMode;
  if (FPatternIndex < FAnimStart) or (FPatternIndex >= FAnimCount + FAnimStart) then
  begin
    FPatternIndex := FAnimStart mod FAnimCount;
    FAnimPos := FAnimStart;
  end;
end;

procedure TAnimatedSprite.OnAnimStart;
begin
 //--//--//
end;

procedure TAnimatedSprite.OnAnimEnd;
begin
 //--//---//
end;

procedure TAnimatedSprite.SetPatternIndex(const Value: Integer);
begin
  Self.FPatternIndex := Value;
  if FImageName = ' ' then
    Exit;
end;

procedure TAnimatedSprite.SetPattern(APatternWidth, APatternHeight: Integer);
var  ColCount,RowCount: integer;
begin
  FPatternWidth := APatternWidth;
  FPatternHeight := APatternHeight;
  if FImageLib <> nil then
  begin
    if FImageLib.ContainsKey(FImageName) then
    begin
       ColCount := FImageLib[FImageName].Width div FPatternWidth;
       RowCount := FImageLib[FImageName].Height div FPatternHeight;
      FPatternCount := (ColCount * RowCount) - 1;
    end
    else
      FPatternCount := 1;
  end;
end;

{$REGION TSpriteEx }

procedure TSpriteEx.SetRed(const Value: Integer);
begin
  inherited;
  Self.FRed := Value;
  SetColor(cRGB1(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSpriteEx.SetGreen(const Value: Integer);
begin
  inherited;
  Self.FGreen := Value;
  SetColor(cRGB1(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSpriteEx.SetBlue(const Value: Integer);
begin
  inherited;
  Self.FBlue := Value;
  SetColor(cRGB1(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSpriteEx.SetAlpha(const Value: Integer);
begin
  inherited;
  Self.FAlpha := Value;
  SetColor(cRGB1(FRed, FGreen, FBlue, FAlpha));
end;

procedure TSpriteEx.SetAngle360(Value: Integer);
begin
  if FAngle360 <> Value then FAngle := DegToRad(Value);
end;

procedure TSpriteEx.SetGroupNumber(AGroupNumber: Integer);
begin
   if (AGroupNumber <> GroupNumber) and (Engine <> nil) then
  begin
    if GroupNumber >= 0 then
      Engine.Groups[GroupNumber].Remove(Self);
    if AGroupNumber >= 0 then
      Engine.Groups[AGroupNumber].Add(Self);
  end;
end;

procedure TSpriteEx.SetSelected(ASelected: Boolean);
begin
  if (ASelected <> FSelected) and (Engine <> nil) then
  begin
    FSelected := ASelected;
    if Selected then
      Engine.CurrentSelected.Add(Self)
    else
      Engine.CurrentSelected.Remove(Self);
    Engine.FObjectsSelected := Engine.CurrentSelected.Count <> 0;
  end;
end;

function TSpriteEx.GetBoundsRect: TRect;
begin
  Result := Bounds(Round(FX), Round(FY), Round(FX + Width), Round(FY + Height));
end;

constructor TSpriteEx.Create(const AParent: TSprite);
begin
  inherited Create(AParent);
  FGroupNumber := -1;
  FImageType := itSpriteSheet;
  FColor1 := $FFFFFFFF;
  FColor2 := $FFFFFFFF;
  FColor3 := $FFFFFFFF;
  FColor4 := $FFFFFFFF;
  FCenterX := 0;
  FCenterY := 0;
  FX1 := 0;
  FY1 := 0;
  FX2 := 10;
  FY2 := 0;
  FX3 := 10;
  FY3 := 10;
  FX4 := 0;
  FY4 := 10;
  FRed := 255;
  FGreen := 255;
  FBlue := 255;
  FAlpha := 255;
  FAngle := 0;
  FScaleX := 1;
  FScaleY := 1;
  FDoCenter := False;
  Offset.X := 0;
  Offset.Y := 0;
  FMirrorMode:=mirrorNormal;
  FMouseEnterFlag := False;
  FMouseDownFlag := False;
  FPositionListX := TList.Create;
  FPositionListY := TList.Create;
  FAttachTo := nil;
end;

destructor TSpriteEx.Destroy;
begin
  GroupNumber := -1;
  Selected := False;
  FPositionListX.Free;
  FPositionListY.Free;
  inherited Destroy;
end;

procedure TSpriteEx.Assign(const Value: TSprite);
begin
    FImageType := TSpriteEx(Value).ImageType;
  FX1 := TSpriteEx(Value).X1;
  FY1 := TSpriteEx(Value).Y1;
  FX2 := TSpriteEx(Value).X2;
  FY2 := TSpriteEx(Value).Y2;
  FX3 := TSpriteEx(Value).X3;
  FY3 := TSpriteEx(Value).Y3;
  FX4 := TSpriteEx(Value).X4;
  FY4 := TSpriteEx(Value).Y4;
  Offset.X := TSpriteEx(Value).Offset.X;
  Offset.Y := TSpriteEx(Value).Offset.Y;
  FCenterX := TSpriteEx(Value).CenterX;
  FCenterY := TSpriteEx(Value).CenterY;
  FMirrorMode:= TSpriteEx(Value).MirrorMode;
  FScaleX := TSpriteEx(Value).ScaleX;
  FScaleY := TSpriteEx(Value).ScaleY;
  FDoCenter := TSpriteEx(Value).DoCenter;
  FRed := TSpriteEx(Value).Red;
  FGreen := TSpriteEx(Value).Green;
  FBlue := TSpriteEx(Value).Blue;
  FAlpha := TSpriteEx(Value).Alpha;
  FColor1 := TSpriteEx(Value).Color1;
  FColor2 := TSpriteEx(Value).Color2;
  FColor3 := TSpriteEx(Value).Color3;
  FColor4 := TSpriteEx(Value).Color4;
  Angle := TSpriteEx(Value).Angle;
end;

procedure TSpriteEx.DoDraw;
var
  Source: TRectangle;
  Dest: TRectangle;
begin
   if not FImageLib.ContainsKey(FImagename) then Exit;

   case MirrorMode of
    mirrorNormal:RectangleSet(@Source, 0, 0,Self.ImageWidth,Self.ImageHeight);
    mirrorX:     RectangleSet(@Source, 0, 0,-Self.ImageWidth,Self.ImageHeight);
    mirrorY:     RectangleSet(@Source, 0, 0,Self.ImageWidth,-Self.ImageHeight);
    mirrorXY:    RectangleSet(@Source, 0, 0,-Self.ImageWidth,-Self.ImageHeight);
   end;

   case TruncMove of
   true: begin
           RectangleSet(@Dest, Round(FX + FWorldX + Offset.X - FEngine.FWorldX),
                       Round(FY + FWorldY + Offset.Y - FEngine.FWorldY),
                       Self.ImageWidth  * ScaleX,
                       Self.ImageHeight * ScaleY);
           DrawTexturePro(FImageLib[FImageName], Source, Dest,
           Vector2Create(0, 0), FAngle, ColorCreate(Fred,FGreen,FBlue,FAlpha));
         end;
   false: begin
            RectangleSet(@Dest, FX + FWorldX + Offset.X - FEngine.FWorldX,
                                FY + FWorldY + Offset.Y - FEngine.FWorldY,
                       Self.ImageWidth  * ScaleX,
                       Self.ImageHeight * ScaleY);
           DrawTexturePro(FImageLib[FImageName], Source, Dest,
           Vector2Create(0, 0), FAngle, ColorCreate(Fred,FGreen,FBlue,FAlpha));
          end;
   end;
end;

procedure TSpriteEx.Draw;
var
  I: Integer;
begin
  if FVisible then
  begin
    if FEngine <> nil then
    begin
      if (X + Offset.X > FEngine.WorldX - Width) and (Y + Offset.Y > FEngine.WorldY - Height) and (X
        + Offset.X < FEngine.WorldX + FEngine.VisibleWidth) and (Y + Offset.Y < FEngine.WorldY +
        FEngine.VisibleHeight) then
      begin
        DoDraw;
        Inc(FEngine.FDrawCount);
      end;
    end;
    if FDrawList <> nil then
    begin
      for I := 0 to FDrawList.Count - 1 do
        TSprite(FDrawList[I]).Draw;
    end;
  end;
end;

procedure TSpriteEx.SetColor(const Color: Cardinal);
begin
  FRed   := GetR(Color);
  FGreen := GetG(Color);
  FBlue  := GetB(Color);
  FAlpha := GetA(Color);
end;

procedure TSpriteEx.SetColor(Red, Green, Blue: Cardinal; Alpha: Cardinal);
begin
  FRed := Red;
  FGreen := Green;
  FBlue := Blue;
  FAlpha := Alpha;
end;

procedure TSpriteEx.LookAt(TargetX, TargetY: Integer);
begin
  Angle := Angle256(TargetX - Trunc(X), TargetY - Trunc(Y)) / 40.3;
end;

procedure TSpriteEx.TowardToAngle(Angle: Integer; Speed: Single;
  DoLookAt: Boolean);
begin
    if DoLookAt then FAngle := Angle / 40;
  X := X + (Sin256(Angle) * Speed);
  Y := Y - (Cos256(Angle) * Speed);
end;

procedure TSpriteEx.TowardToPos(TargetX, TargetY: Integer; Speed: Single;
  DoLookAt: Boolean);
var
  Direction: Integer;
begin
  if DoLookAt then
    LookAt(TargetX, TargetY);
  Direction := Trunc(Angle256(TargetX - Trunc(Self.X), TargetY - Trunc(Self.Y)));
  if (not SameValue(X, TargetX, Speed + 1)) or (not SameValue(Y, TargetY, Speed + 1)) then
  begin
    X := X + (Sin256(Direction) * Speed);
    Y := Y - (Cos256(Direction) * Speed);
  end
  else
  begin
    // make sure it gets to final pos
    X := TargetX;
    Y := TargetY;
  end;
end;

procedure TSpriteEx.RotateToAngle(Angle: Integer; RotateSpeed, MoveSpeed: Single
  );
// toward(rotate self angle automation)(straight) move direction
// and move by rotation speed(to destination angle)
begin
    FDestAngle := Angle;
  if not SameValue(FSrcAngle, FDestAngle, RotateSpeed + 1) then
  begin
    if AngleDiff(FSrcAngle, FDestAngle) > 0 then
      FSrcAngle := FSrcAngle + RotateSpeed;
    if AngleDiff(FSrcAngle, FDestAngle) < 0 then
      FSrcAngle := FSrcAngle - RotateSpeed;
  end;
  if FSrcAngle > 255 then
    FSrcAngle := FSrcAngle - 255;
  if FSrcAngle < 0 then
    FSrcAngle := 255 + FSrcAngle;
  FAngle := FSrcAngle / 40;
  X := X + (Sin256(Trunc(FSrcAngle)) * MoveSpeed);
  Y := Y - (Cos256(Trunc(FSrcAngle)) * MoveSpeed);
end;

procedure TSpriteEx.RotateToPos(DestX, DestY: Integer; RotateSpeed,
  MoveSpeed: Single);
// toward(rotate self angle automation)(straight) move  direction
// and move by rotation speed(to destination position)
begin
    FDestAngle := Trunc(Angle256(DestX - Trunc(X), DestY - Trunc(Y)));

  if not SameValue(FSrcAngle, FDestAngle, RotateSpeed + 1) then
  begin
    if AngleDiff(FSrcAngle, FDestAngle) > 0 then
      FSrcAngle := FSrcAngle + RotateSpeed;
    if AngleDiff(FSrcAngle, FDestAngle) < 0 then
      FSrcAngle := FSrcAngle - RotateSpeed;
  end;
  if FSrcAngle > 255 then
    FSrcAngle := FSrcAngle - 255;
  if FSrcAngle < 0 then
    FSrcAngle := 255 + FSrcAngle;
  FAngle := FSrcAngle / 40;
  X := X + (Sin256(Trunc(FSrcAngle)) * MoveSpeed);
  Y := Y - (Cos256(Trunc(FSrcAngle)) * MoveSpeed);
end;

procedure TSpriteEx.CircleToAngle(Angle, LookAtX, LookAtY: Integer;
  RotateSpeed, MoveSpeed: Single; DoLookAt: Boolean);
// move by rotation speed to destination angle,but not straight direction(no rotate self)
// but can be custom angle
begin
    if DoLookAt then
    LookAt(LookAtX, LookAtY);
  FDestAngle := Angle;
  if not SameValue(FSrcAngle, FDestAngle, RotateSpeed + 1) then
  begin
    if AngleDiff(FSrcAngle, FDestAngle) > 0 then
      FSrcAngle := FSrcAngle + RotateSpeed;
    if AngleDiff(FSrcAngle, FDestAngle) < 0 then
      FSrcAngle := FSrcAngle - RotateSpeed;
  end;
  if FSrcAngle > 255 then
    FSrcAngle := FSrcAngle - 255;
  if FSrcAngle < 0 then
    FSrcAngle := 255 + FSrcAngle;
  X := X + (Sin256(Trunc(FSrcAngle)) * MoveSpeed);
  Y := Y - (Cos256(Trunc(FSrcAngle)) * MoveSpeed);
end;

procedure TSpriteEx.CircleToPos(DestX, DestY, LookAtX, LookAtY: Integer;
  RotateSpeed, MoveSpeed: Single; DoLookAt: Boolean);
// move by rotation speed to destination position,but not straight direction(no rotae self)
// but can be custom angle
begin
    if DoLookAt then
    LookAt(LookAtX, LookAtY);
  FDestAngle := Trunc(Angle256(DestX - Trunc(X), DestY - Trunc(Y)));

  if not SameValue(FSrcAngle, FDestAngle, RotateSpeed + 1) then
  begin
    if AngleDiff(FSrcAngle, FDestAngle) > 0 then
      FSrcAngle := FSrcAngle + RotateSpeed;
    if AngleDiff(FSrcAngle, FDestAngle) < 0 then
      FSrcAngle := FSrcAngle - RotateSpeed;
  end;
  if FSrcAngle > 255 then
    FSrcAngle := FSrcAngle - 255;
  if FSrcAngle < 0 then
    FSrcAngle := 255 + FSrcAngle;
  X := X + (Sin256(Trunc(FSrcAngle)) * MoveSpeed);
  Y := Y - (Cos256(Trunc(FSrcAngle)) * MoveSpeed);
end;

procedure TSpriteEx.Attach(Sprite: TSprite);
var
  CurrentPositionX, PredPositionX, LastPositionX: ^Single;
  CurrentPositionY, PredPositionY, LastPositionY: ^Single;
begin
  FAttachTo := Sprite;
  New(CurrentPositionX);
  New(CurrentPositionY);
  CurrentPositionX^ := FAttachTo.FX;
  CurrentPositionY^ := FAttachTo.FY;
  FPositionListX.Add(CurrentPositionX);
  FPositionListY.Add(CurrentPositionY);
  if FPositionListX.Count > 2 then
  begin
    LastPositionX := FPositionListX.Last;
    LastPositionY := FPositionListY.Last;
    PredPositionX := FPositionListX.Items[1];
    PredPositionY := FPositionListY.Items[1];
    FX := FX + (LastPositionX^ - PredPositionX^);
    FY := FY + (LastPositionY^ - PredPositionY^);
    FPositionListX.Delete(0);
    FPositionListY.Delete(0);
  end;
end;

procedure TSpriteEx.Detach;
begin
  FAttachTo := nil;
end;

function TSpriteEx.GetSpriteAt(XX, YY: Integer): TSprite;

  procedure Collision_GetSpriteAt(X, Y: Double; Sprite: TSpriteEx);
  var
    I, SWidth, SHeight: Integer;
    X1, Y1: Double;
    X2, Y2: Double;
    IsCollision: Boolean;
  begin
    if (Sprite.Parent <> nil) and not Sprite.Parent.Visible then
      Exit;
    Sprite.Collisioned := False;
    if Sprite.CanCollision then
    begin
      SWidth := Round(Sprite.Width * Sprite.ScaleX);
      SHeight := Round(Sprite.Height * Sprite.ScaleY);
{      if Sprite.DrawMode = 1 then
      begin
        X1 := X - Sprite.X - Sprite.Parent.X;
        Y1 := Y - Sprite.Y - Sprite.Parent.Y;
      end
      else }
      if Sprite.DoCenter then
      begin
        X1 := X - Sprite.X - Sprite.Parent.X - Sprite.Width / 2;
        Y1 := Y - Sprite.Y - Sprite.Parent.Y - Sprite.Height / 2;
      end
      else
      begin
        X1 := X - Sprite.X - Sprite.Parent.X - SWidth / 2;
        Y1 := Y - Sprite.Y - Sprite.Parent.Y - SHeight / 2;
      end;
      X2 := Y1 * Sin(Sprite.Angle) + X1 * Cos(Sprite.Angle);
      Y2 := Y1 * Cos(Sprite.Angle) - X1 * Sin(Sprite.Angle);

      IsCollision := Sprite.Visible and PointInRect(Point(Round(X2), Round(Y2)), Bounds(-SWidth div
        2, -SHeight div 2, SWidth, SHeight));

      if IsCollision then
      begin
        if (Result = nil) or (Sprite.Z > Result.Z) then
          Result := Sprite;
      end;
    end;

    for I := 0 to Sprite.Count - 1 do
      Collision_GetSpriteAt(X, Y, TSpriteEx(Sprite.Items[I]));
  end;

var
  I: Integer;
begin
  Result := nil;
  if Self.FEngine <> nil then
    Collision_GetSpriteAt(X, Y, TSpriteEx(Self));
  for I := 0 to Count - 1 do
    Collision_GetSpriteAt(X, Y, TSpriteEx(Items[I]));
  if Result <> nil then
  begin
    Result.Collisioned := True;
    Result.DoCollision(Result);
  end;

end;

function TSpriteEx.GetDistance(Sprite1, Sprite2: TSprite): Real;
begin
  Result := Hypot(Sprite1.X - Sprite2.X, Sprite1.Y - Sprite2.Y);
end;

function TSpriteEx.MouseInRect: Boolean;
begin
  Result := CheckCollisionPointRec(GetMousePosition,
  RectangleCreate(FActiveRect.Left - Trunc(FEngine.WorldX), FActiveRect.Top - Trunc(FEngine.WorldY),
    FActiveRect.Right - Trunc(FEngine.WorldX), FActiveRect.Bottom - Trunc(FEngine.WorldY)));
end;

function TSpriteEx.SpriteInRect1(InArea: TRect): Boolean;
begin
  Result := RectInRect(FActiveRect, InArea);
end;

function TSpriteEx.SpriteInRect2(InArea: TRect): Boolean;
begin
  Result := RectInRect(Rect(FActiveRect.Left - Trunc(FEngine.WorldX), FActiveRect.Top - Trunc(FEngine.WorldY),
    FActiveRect.Right - Trunc(FEngine.WorldX), FActiveRect.Bottom - Trunc(FEngine.WorldY)), InArea);
end;

procedure TSpriteEx.DoMouseEvent;
begin
  if MouseInRect then
  begin
    if FMouseEnterFlag = False then
    begin
      OnMouseEnter;
      FMouseEnterFlag := True;
    end;
  end;

  if (not MouseInRect) then
  begin
    if FMouseEnterFlag = True then
    begin
      OnMouseLeave;
      FMouseEnterFlag := False;
    end;
  end;
end;

procedure TSpriteEx.OnMouseEnter;
begin
 // -- // -- //
end;

procedure TSpriteEx.OnMouseLeave;
begin
 // -- // -- //
end;

procedure TSpriteEx.OnMouseMove;
begin
 // -- // -- //
end;

procedure TSpriteEx.OnLMouseDown;
begin
 // -- // -- //
end;

procedure TSpriteEx.OnLMouseUp;
begin
 // -- // -- //
end;

procedure TSpriteEx.OnRMouseDown;
begin
 // -- // -- //
end;

procedure TSpriteEx.OnRMouseUp;
begin
 // -- // -- //
end;

procedure TSpriteEx.OnMouseDbClick;
begin
 // -- // -- //
end;

procedure TSpriteEx.OnMouseWheelUp;
begin
  // -- // -- //
end;

procedure TSpriteEx.OnMouseWheelDown;
begin
 // -- // -- //
end;

procedure TSpriteEx.OnMouseDrag;
begin
 // -- // -- //
end;
{$ENDREGION}

{$REGION TSpriteEngine }
procedure TSpriteEngine.SetGroupCount(AGroupCount: Integer);
var
  Index: Integer;
begin
  if (AGroupCount <> FGroupCount) and (AGroupCount >= 0) then
  begin
    if FGroupCount > AGroupCount then
    begin // remove groups
      for Index := AGroupCount to FGroupCount - 1 do
      begin
        ClearGroup(Index);
        FGroups[Index].Free;
      end;
      SetLength(FGroups, AGroupCount);
    end
    else
    begin // add groups
      SetLength(FGroups, AGroupCount);
      for Index := FGroupCount to AGroupCount - 1 do
        FGroups[Index] := TList.Create;
    end;
    FGroupCount := Length(FGroups);
  end;

end;

function TSpriteEngine.GetGroup(Index: Integer): TList;
begin
    if (Index >= 0) or (Index < FGroupCount) then
    Result := FGroups[Index]
  else
    Result := nil;
end;

constructor TSpriteEngine.Create(const AParent: TSprite);
begin
  inherited Create(AParent);
  FDeadList := TList.Create;
  FCurrentSelected := TList.Create;
  GroupCount := 10;
  FVisibleWidth := 800;
  FVisibleHeight := 600;
  FDoMouseEvent := False;
  FZCounter := 3;
end;

destructor TSpriteEngine.Destroy;
begin
  ClearCurrent;
  GroupCount := 0;
  FDeadList.Free;
  inherited Destroy;
  FCurrentSelected.Free;
  inherited Destroy;
end;

procedure TSpriteEngine.Draw;
begin
  FDrawCount := 0;
  inherited Draw;
end;

procedure TSpriteEngine.DrawEx(TypeList: array of string);
var i:TSprite; i2:String;
begin
  if FVisible then
  begin
    if FEngine <> nil then
    begin
      if (X > FEngine.WorldX - Width) and (Y > FEngine.WorldY - Height) and (X < FEngine.WorldX +
        FEngine.VisibleWidth) and (Y < FEngine.WorldY + FEngine.VisibleHeight) then
      begin
        DoDraw;
        Inc(FEngine.FDrawCount);
      end;
    end;

    if FDrawList <> nil then
    begin
      for I in FDrawList do
        for  i2 in TypeList do
        if TSprite(I).ClassName = i2 then TSprite(I).Draw;
    end;
  end;
end;

procedure TSpriteEngine.Dead;
begin
  while FDeadList.Count > 0 do
      TSprite(FDeadList[FDeadList.Count - 1]).Free;
end;

function TSpriteEngine.Select(Point: TPoint; Filter: array of TSpriteClass;
  Add_: Boolean): TSprite;
var
  Index, Index2: Integer;
begin
  Assert(Length(Filter) <> 0, 'Filter = []');
  if not Add_ then
    ClearCurrent;
  // By searching the Drawlist in reverse
  // we select the highest sprite if the sprit is under the point
  Assert(FDrawList <> nil, 'FDrawList = nil');
  if Length(Filter) = 1 then
  begin
    for Index := FDrawList.Count - 1 downto 0 do
    begin
      Result := FDrawList[Index];
      if (Result is Filter[0]) and PointInRect(Point, TSpriteEx(Result).GetBoundsRect) then
      begin
        TSpriteEx(Result).Selected := True;
        FObjectsSelected := CurrentSelected.Count <> 0;
        Exit;
      end;
    end
  end
  else
  begin
    for Index := FDrawList.Count - 1 downto 0 do
    begin
      Result := FDrawList[Index];
      for Index2 := 0 to High(Filter) do
      begin
       if (Result is Filter[Index2]) and PointInRect(Point, TSpriteEx(Result).GetBoundsRect) then
        begin
          TSpriteEx(Result).Selected := True;
          FObjectsSelected := CurrentSelected.Count <> 0;
          Exit;
        end;
      end;
    end
  end;
  Result := nil;

end;

function TSpriteEngine.Select(Point: TPoint; Add_: Boolean): TSprite;
begin
  Result := Select(Point, [TSprite], Add_);
end;

procedure TSpriteEngine.ClearCurrent;
begin
  while CurrentSelected.Count <> 0 do
   TSpriteEx(CurrentSelected[CurrentSelected.Count - 1]).Selected := False;
  FObjectsSelected := False;
end;

procedure TSpriteEngine.ClearGroup(GroupNumber: Integer);
var
  Index: Integer;
  Group: TList;
begin
  Group := Groups[GroupNumber];
  if Group <> nil then
    for Index := 0 to Group.Count - 1 do
      TSpriteEx(Group[Index]).Selected := False;
end;

procedure TSpriteEngine.GroupToCurrent(GroupNumber: Integer; Add_: Boolean = false);
var
  Group: TList;
  Index: Integer;
begin
  if not Add_ then
  ClearCurrent;
  Group := Groups[GroupNumber];
  if Group <> nil then
    for Index := 0 to Group.Count - 1 do
      TSpriteEx(Group[Index]).Selected := True;
end;

procedure TSpriteEngine.CurrentToGroup(GroupNumber: Integer; Add_: Boolean = false);
var
  Group: TList;
  Index: Integer;
begin
  Group := Groups[GroupNumber];
  if Group = nil then
    Exit;
  if not Add_ then
    ClearGroup(GroupNumber);
  for Index := 0 to Group.Count - 1 do
    TSpriteEx(Group[Index]).GroupNumber := GroupNumber;
end;

procedure TSpriteEngine.GroupSelect(const Area: TRect;
  Filter: array of TSpriteClass; Add_: Boolean);
var
  Index, Index2: Integer;
  Sprite: TSprite;
begin
  Assert(Length(Filter) <> 0, 'Filter = []');
  if not Add_ then
    ClearCurrent;
  if Length(Filter) = 1 then
  begin
    for Index := 0 to Count - 1 do
    begin
      Sprite := TSpriteEx(Items[Index]);
      if (Sprite is Filter[0]) and OverlapRect(TSpriteEx(Sprite).GetBoundsRect, Area) then
        TSpriteEx(Sprite).Selected := True;
    end
  end
  else
  begin
    for Index := 0 to Count - 1 do
    begin
      Sprite := Items[Index];
      for Index2 := 0 to High(Filter) do
      begin
        if (Sprite is Filter[Index2]) and OverlapRect(TSpriteEx(Sprite).GetBoundsRect, Area) then
        begin
          TSpriteEx(Sprite).Selected := True;
          Break;
        end;
      end;
    end
  end;
  FObjectsSelected := CurrentSelected.Count <> 0;

end;

procedure TSpriteEngine.GroupSelect(const Area: TRect; Add_: Boolean = false);
begin
  GroupSelect(Area, [TSprite], Add_);
end;
{$ENDREGION}

{$REGION TSprite }
procedure TSprite.Add(Sprite: TSprite);
begin
    if FList = nil then
  begin
    FList :=  specialize TList<TSprite>.Create;
    FDrawList := specialize TList<TSprite>.Create;
  end;
  FList.Add(Sprite);
end;

procedure TSprite.Remove(Sprite: TSprite);
begin
  FList.Remove(Sprite);
  FDrawList.Remove(Sprite);
  if FList.Count = 0 then
  begin
    FList.Free;
    FList := nil;
    FDrawList.Free;
    FDrawList := nil;
  end;
end;

procedure TSprite.AddDrawList(Sprite: TSprite);
var
  L, H, I, C: Integer;
begin
  L := 0;
  H := FDrawList.Count - 1;
  while L <= H do
  begin
    I := (L + H) div 2;
    C := TSprite(FDrawList[I]).Z - Sprite.Z - 1;
    if C < 0 then
      L := I + 1
    else
      H := I - 1;
  end;
  FDrawList.Insert(L, Sprite);
end;

procedure TSprite.Draw;
var
  I: Integer;
begin
  if FVisible then
  begin
    if FEngine <> nil then
    begin
      if (X > FEngine.WorldX - Width) and (Y > FEngine.WorldY - Height) and (X < FEngine.WorldX +
        FEngine.VisibleWidth) and (Y < FEngine.WorldY + FEngine.VisibleHeight) then
      begin
        DoDraw;
        Inc(FEngine.FDrawCount);
      end;
    end;
    if FDrawList <> nil then
    begin
      for I := 0 to FDrawList.Count - 1 do
        TSprite(FDrawList[I]).Draw;
    end;
  end;

end;

function TSprite.GetCount: Integer;
begin
  if FList <> nil then
    Result := FList.Count
  else
    Result := 0;
end;

function TSprite.GetItem(Index: Integer): TSprite;
begin
  if FList <> nil then
    Result := FList[Index]
  else
    raise ESpriteError.CreateFmt('Index of the list exceeds the range. (%d)', [Index]);
end;

function TSprite.GetImageWidth: Integer;
begin
  Result := FImageLib[FImageName].width;
end;

function TSprite.GetImageHeight: Integer;
begin
  Result := FImageLib[FImageName].height;
end;

procedure TSprite.DoDraw;
begin
    if not FVisible then Exit;  if FImageLib = nil then Exit;

 {   case  FBlendingEffect of
    Undefined: BeginBlendMode(-1);
    Alpha:BeginBlendMode(BLEND_ALPHA);
    Additive:BeginBlendMode(BLEND_ADDITIVE);
    Multiplied:BeginBlendMode(BLEND_MULTIPLIED);
    AddColors:BeginBlendMode(BLEND_ADD_COLORS);
    Subtract:BeginBlendMode(BLEND_SUBTRACT_COLORS);
    Custom:BeginBlendMode(BLEND_CUSTOM);
    end;}

    BeginBlendMode(Ord(FBlendingEffect));

    case FTruncMove of
     True:
        DrawTexture(FImageLib[FImageName], Round(FX + FWorldX - FEngine.FWorldX), Round(FY +
        FWorldY - FEngine.FWorldY),WHITE);

     False:
      DrawTextureV(FImageLib[FImageName],
      Vector2Create(FX + FWorldX - FEngine.FWorldX, FY + FWorldY -FEngine.FWorldY),
      WHITE);
    end;

    EndBlendMode;
end;

procedure TSprite.DoMove(const MoveCount: Single);
begin
  // -- // -- //
end;

procedure TSprite.DoCollision(const Sprite: TSprite);
begin
  // --- // -- //
end;

procedure TSprite.SetName(const Value: string);
begin
  Self.FName := Value;
end;

procedure TSprite.SetImageName(const Value: string);
begin
  //nothing
end;

procedure TSprite.SetX(const Value: Single);
begin
  Self.FX := Value;
end;

procedure TSprite.SetY(const Value: Single);
begin
  Self.FY := Value;
end;

procedure TSprite.SetZ(const Value: Integer);
begin
  if FZ <> Value then
  begin
    FZ := Value;
    if Parent <> nil then
    begin
      if FZSet then Parent.FDrawList.Remove(Self);
      Parent.AddDrawList(Self);
      FZSet := True;
    end;
  end;
end;

constructor TSprite.Create(const AParent: TSprite);
begin
  inherited Create;
    FParent := AParent;
    if FParent <> nil then
    begin
      FParent.Add(Self);
      if FParent is TSpriteEngine then
        FEngine := TSpriteEngine(FParent)
      else
        FEngine := FParent.Engine;
     // Inc(FEngine.FAllCount);
    end;
    FX := 200;
    FY := 200;
    FZ := 0;
    if Z = 0 then
      Z := 1;
    FWidth := 64;
    FHeight := 64;
    FName := '';
    FZ := 0;
    FDoCollision := False;
    FMoved := True;         //totototototodoooooooooooo
    FBlendingEffect := TBlendingEffect.Undefined;  // <----------
    FVisible := True;
    TruncMove := True;
    FTag := 0;
    FCollideMode := cmCircle;
end;

destructor TSprite.Destroy;
begin
  Clear;
  if FParent <> nil then
  begin { #todo : fix toengine }
    //Dec(FEngine.FAllCount);
    FParent.Remove(Self);
    FEngine.FDeadList.Remove(Self);
  end;
  FList.Free;
  FDrawList.Free;
  inherited Destroy;
end;

procedure TSprite.Assign(const Value: TSprite);
begin
  FName := Value.Name;
  FImageName := Value.ImageName;
  FX := Value.X;
  FY := Value.Y;
  FZ := Value.Z;
  FWorldX := Value.WorldX;
  FWorldY := Value.WorldY;
  FImageIndex := Value.ImageIndex;
  FCollideMode := Value.CollideMode;
  FCollisioned := Value.Collisioned;
  FCollidePos := Value.CollidePos;
  FCollideRadius := Value.CollideRadius;
  FCollideRect := Value.CollideRect;
  FCollideQuadrangle := Value.CollideQuadrangle;
  FMoved := Value.Moved;
  FBlendingEffect := Value.BlendingEffect;
  FVisible := Value.Visible;
  FTag := Value.Tag;
end;

procedure TSprite.Clear;
begin
  while Count > 0 do
    Items[Count - 1].Free;
end;

procedure TSprite.Move(const MoveCount: Single);
var
  I: Integer;
begin
  if FMoved then
  begin
    DoMove(MoveCount);
    for I := 0 to Count - 1 do
      Items[I].Move(MoveCount);
  end;
end;

procedure TSprite.SetPos(X, Y: Single);
begin
  FX := X;
  FY := Y;
end;

procedure TSprite.SetPos(X, Y: Single; Z: Integer);
begin
  FX := X;
  FY := Y;
  FZ := Z;
end;

procedure TSprite.Collision(const Other: TSprite);
var
  Delta: Real;
  IsCollide: Boolean;
begin
  IsCollide := False;

  if (FCollisioned) and (Other.FCollisioned) and (not FDeaded) and (not Other.FDeaded) then
  begin
    case FCollideMode of
      cmCircle:
        begin
          Delta := Sqrt(Sqr(Self.FCollidePos.X - Other.FCollidePos.X) + Sqr(Self.FCollidePos.Y -
            Other.FCollidePos.Y));
          IsCollide := (Delta < (Self.FCollideRadius + Other.FCollideRadius));
        end;
      cmRect:
        begin
          IsCollide := OverlapRect(Self.FCollideRect, Other.FCollideRect);
        end;
      cmQuadrangle:
        begin
          IsCollide := OverlapQuadrangle(Self.FCollideQuadrangle, Other.FCollideQuadrangle);
        end;
      cmPolygon:
        begin
          IsCollide := OverlapPolygon(Self.FCollidePolygon, Other.FCollidePolygon);
        end;
    end;

    if IsCollide then
    begin
      DoCollision(Other);
      Other.DoCollision(Self);
    end;
 end;
end;

procedure TSprite.Collision;
var
  I: Integer;
begin
  if (FEngine <> nil) and (not FDeaded) and (Collisioned) then
  begin
    for I := 0 to Engine.Count - 1 do
      Self.Collision(Engine.Items[I]);
  end;
end;

procedure TSprite.Dead;
begin
 if (FEngine <> nil) and (not FDeaded) then
  begin
    FDeaded := True;
    FEngine.FDeadList.Add(Self);
  end;
end;
{$ENDREGION}

{$REGION TAnimations }
function TAnimations.GetItem(Index: Integer): TFrameRec;
begin
  if (Index >= 0) and (Index < Length(FrameData)) then Result := FrameData[Index];
end;

function TAnimations.GetItemCount(): Integer;
begin
  Result := Length(FrameData);
end;

procedure TAnimations.InitSearchObjects();
var
  I: Integer;
begin
  if (Length(FrameData) <> Length(SearchObjects)) then
    SetLength(SearchObjects, Length(FrameData));
  for I := 0 to Length(FrameData) - 1 do
    SearchObjects[I] := I;
end;

procedure TAnimations.SwapSearchObjects(Index1, Index2: Integer);
var
  Aux: Integer;
begin
  Aux := SearchObjects[Index1];
  SearchObjects[Index1] := SearchObjects[Index2];
  SearchObjects[Index2] := Aux;
end;

function TAnimations.CompareSearchObjects(Obj1, Obj2: TFrameRec): Integer;
begin
Result := CompareText(Obj1.FrameName, Obj2.FrameName);
end;

function TAnimations.SplitSearchObjects(Start, Stop: Integer): Integer;
var
  Left, Right: Integer;
  Pivot: TFrameRec;
begin
  Left := Start + 1;
  Right := Stop;
  Pivot := FrameData[SearchObjects[Start]];
  while (Left <= Right) do
  begin
    while (Left <= Stop) and (CompareSearchObjects(FrameData[SearchObjects[Left]], Pivot) < 0) do
      Inc(Left);

    while (Right > Start) and (CompareSearchObjects(FrameData[SearchObjects[Right]], Pivot) >= 0) do
      Dec(Right);

    if (Left < Right) then
      SwapSearchObjects(Left, Right);
  end;

  SwapSearchObjects(Start, Right);
  Result := Right;

end;

procedure TAnimations.SortSearchObjects(Start, Stop: Integer);
var
  SplitPt: Integer;
begin
  if (Start < Stop) then
  begin
    SplitPt := SplitSearchObjects(Start, Stop);
    SortSearchObjects(Start, SplitPt - 1);
    SortSearchObjects(SplitPt + 1, Stop);
  end;
end;

procedure TAnimations.UpdateSearchObjects();
begin
  InitSearchObjects();
  SortSearchObjects(0, Length(SearchObjects) - 1);
  SearchDirty := False;
end;

function TAnimations.GetFrame(const Name: string): TFrameRec;
var
  Index: Integer;
begin
  Index := IndexOf(Name);
  if (Index <> -1) then
    Result := FrameData[Index];
end;

function TAnimations.IndexOf(const Name: string): Integer;
var
  Lo, Hi, Mid: Integer;
begin
  if (SearchDirty) then
    UpdateSearchObjects();
  Result := -1;
  Lo := 0;
  Hi := Length(SearchObjects) - 1;
  while (Lo <= Hi) do
  begin
    Mid := (Lo + Hi) div 2;
    if (CompareText(FrameData[SearchObjects[Mid]].FrameName, Name) = 0) then
    begin
      Result := SearchObjects[Mid];
      Break;
    end;
    if (CompareText(FrameData[SearchObjects[Mid]].FrameName, Name) > 0) then
      Hi := Mid - 1
    else
      Lo := Mid + 1;
  end;
end;

procedure TAnimations.Remove(Index: Integer);
var
  I: Integer;
begin
  if (Index < 0) or (Index >= Length(FrameData)) then
    Exit;
  for I := Index to Length(FrameData) - 2 do
    FrameData[I] := FrameData[I + 1];
  SetLength(FrameData, Length(FrameData) - 1);
  SearchDirty := True;
end;

procedure TAnimations.AddFrames(FrameName: string; Frames: array of Cardinal);
var
  I, Index: Integer;
begin
  Index := Length(FrameData);
  SetLength(FrameData, Index + 1);
  FrameData[Index].FrameName := FrameName;
  SetLength(FrameData[Index].Frames, High(Frames) + 1);
  for I := 0 to High(Frames) do
    FrameData[Index].Frames[I] := Frames[I];
  SearchDirty := True;
end;

procedure TAnimations.RemoveAll();
begin
  SetLength(FrameData, 0);
  SearchDirty := True;
end;

procedure TAnimations.MarkSearchDirty();
begin
  SearchDirty := True;
end;

constructor TAnimations.Create();
begin
  SearchDirty := False;
end;

destructor TAnimations.Destroy();
begin
   RemoveAll();
  inherited Destroy();
end;
{$ENDREGION}

end.
