unit ray_math_2d;

interface

const
  EPS = 0.000001;

  pi      = 3.141592654;
  rad2deg = 57.29578049;
  deg2rad = 0.017453292;

  ORIENTATION_LEFT  = -1;
  ORIENTATION_RIGHT = 1;
  ORIENTATION_ZERO  = 0;



function min( a, b : Single ) : Single; {$IFDEF USE_INLINE} inline; {$ENDIF}
function max( a, b : Single ) : Single; {$IFDEF USE_INLINE} inline; {$ENDIF}

procedure m_SinCos( Angle : Single; out s, c : Single ); {$IFDEF USE_ASM} assembler; {$ELSE} {$IFDEF USE_INLINE} inline; {$ENDIF} {$ENDIF}

procedure InitCosSinTables;
procedure InitCosTable;
function  m_Cos( Angle : Integer ) : Single;
function  m_Sin( Angle : Integer ) : Single;
function  m_Distance( x1, y1, x2, y2 : Single ) : Single;
function  m_FDistance( x1, y1, x2, y2 : Single ) : Single;
function  m_Angle( x1, y1, x2, y2 : Single ) : Single;
function  m_Orientation( x, y, x1, y1, x2, y2 : Single ) : Integer;
function  m_Angle256(x, y: Integer): Single;
function  m_Cos256(i: Integer): Single;
function  m_Sin256(i: Integer): Single;
var
  cosTable :   array[ 0..360 ] of Single;
  sinTable :   array[ 0..360 ] of Single;
  CosTable256: array[0..255] of Single;

implementation


function ArcTan2( dx, dy : Single ) : Single;
begin
   // Result := abs( ArcTan( dy / dx ) * ( 180 / pi ) );
end;


function min( a, b : Single ) : Single; {$IFDEF USE_INLINE} inline; {$ENDIF}
begin
  if a > b Then Result := b else Result := a;
end;

function max( a, b : Single ) : Single; {$IFDEF USE_INLINE} inline; {$ENDIF}
begin
  if a > b Then Result := a else Result := b;
end;

procedure m_SinCos( Angle : Single; out s, c : Single ); {$IFDEF USE_ASM} assembler; {$ELSE} {$IFDEF USE_INLINE} inline; {$ENDIF} {$ENDIF}
{$IFDEF USE_ASM}
asm
{$IFDEF CPUi386}
  FLD Angle
  FSINCOS
  FSTP [EDX]
  FSTP [EAX]
{$ENDIF}
end;
{$ELSE}
begin
  s := Sin( Angle );
  c := Cos( Angle );
end;
{$ENDIF}

procedure InitCosSinTables;
  var
    i         : Integer;
    rad_angle : Single;
begin
  for i := 0 to 360 do
    begin
      rad_angle := i * ( pi / 180 );
      cosTable[ i ] := cos( rad_angle );
      sinTable[ i ] := sin( rad_angle );
    end;
end;

procedure InitCosTable;
var
  i: Integer;
begin
  for i := 0 to 255 do
    CosTable256[i] := Cos((i / 256) * 2 * PI);
end;

function m_Cos( Angle : Integer ) : Single;
begin
  if Angle > 360 Then
    DEC( Angle, ( Angle div 360 ) * 360 )
  else
    if Angle < 0 Then
      INC( Angle, ( abs( Angle ) div 360 + 1 ) * 360 );
  Result := cosTable[ Angle ];
end;

function m_Sin( Angle : Integer ) : Single;
begin
  if Angle > 360 Then
    DEC( Angle, ( Angle div 360 ) * 360 )
  else
    if Angle < 0 Then
      INC( Angle, ( abs( Angle ) div 360 + 1 ) * 360 );
  Result := sinTable[ Angle ];
end;

function m_Distance( x1, y1, x2, y2 : Single ) : Single;
begin
  Result := sqrt( sqr( x1 - x2 ) + sqr( y1 - y2 ) );
end;

function m_FDistance( x1, y1, x2, y2 : Single ) : Single;
begin
  Result := sqr( x1 - x2 ) + sqr( y1 - y2 );
end;

function m_Angle( x1, y1, x2, y2 : Single ) : Single;
  var
    dx, dy : Single;
begin
  dx := ( X1 - X2 );
  dy := ( Y1 - Y2 );

  if dx = 0 Then
    begin
      if dy > 0 Then
        Result := 90
      else
        Result := 270;
      exit;
    end;

  if dy = 0 Then
    begin
      if dx > 0 Then
        Result := 0
      else
        Result := 180;
      exit;
    end;

  if ( dx < 0 ) and ( dy > 0 ) Then
    Result := 180 - ArcTan2( dx, dy )
  else
    if ( dx < 0 ) and ( dy < 0 ) Then
      Result := 180 + ArcTan2( dx, dy )
    else
      if ( dx > 0 ) and ( dy < 0 ) Then
        Result := 360 - ArcTan2( dx, dy )
      else
        Result := ArcTan2( dx, dy )
end;

function m_Orientation( x, y, x1, y1, x2, y2 : Single ) : Integer;
  var
    orientation : Single;
begin
  orientation := ( x2 - x1 ) * ( y - y1 ) - ( x - x1 ) * ( y2 - y1 );

  if orientation > 0 Then
    Result := ORIENTATION_RIGHT
  else
    if orientation < 0 Then
      Result := ORIENTATION_LEFT
    else
      Result := ORIENTATION_ZERO;
end;

function m_Angle256(X, Y: Integer): Single;
begin
  Result := (Arctan2(X, Y) *  - 40.743665431) + 128;
end;

function m_Cos256(i: Integer): Single;
begin
  Result := CosTable256[i and 255];
end;

function m_Sin256(i: Integer): Single;
begin
  Result := CosTable256[(i + 192) and 255];
end;



initialization
  InitCosSinTables();
  InitCosTable();
finalization


end.
