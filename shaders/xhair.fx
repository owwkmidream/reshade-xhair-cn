/**
 * reshade-xhair 1.3.1
 * ReShade Crosshair Shader Overlay
 *
 *  Copyright 2020 peelz
 */

#include "Reshade.fxh"

#define CATEGORY_GENERAL "常规"
#define CATEGORY_XHAIR_COMPOSITE "组合十字准心"
#define CATEGORY_XHAIR_CROSS "【十字】准心"
#define CATEGORY_XHAIR_CIRCLE "【圆形】准心"

#define MAX_CROSS_OUTLINE_THICKNESS 10
#define MAX_CIRCLE_OUTLINE_THICKNESS 10.0

#if !defined(__RESHADE__) || __RESHADE__ < 40001
  #define UI_TYPE_SLIDER "drag"
#else
  #define UI_TYPE_SLIDER "slider"
#endif

/**
 * General Settings
 */

uniform int OffsetX <
  ui_category = CATEGORY_GENERAL;
  ui_type = "drag";
  ui_min = -(BUFFER_WIDTH / 2); ui_max = (BUFFER_WIDTH / 2);  
  ui_label = "X 轴偏移";
  ui_tooltip = "从屏幕中心水平偏移准心。";
> = 0;

uniform int OffsetY <
  ui_category = CATEGORY_GENERAL;
  ui_type = "drag";
  ui_min = -(BUFFER_HEIGHT / 2); ui_max = (BUFFER_HEIGHT / 2);
  ui_label = "Y 轴偏移";
  ui_tooltip = "从屏幕中心垂直偏移准心。";
> = 0;

uniform int XhairType <
  ui_category = CATEGORY_GENERAL;
  ui_type = "combo";
  ui_items = "十字\0圆形\0T 形\0";
  ui_label = "准心类型";
> = 0;

uniform float XhairOpacity <
  ui_category = CATEGORY_GENERAL;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_label = "准心透明度";
> = 1.0;

uniform int HideOnRMB <
  ui_category = CATEGORY_GENERAL;
  ui_type = "combo";
  ui_items = "按住\0切换\0禁用\0";
  ui_label = "按右键隐藏";
  ui_tooltip = "控制在点击右键时是否隐藏准心。";
> = 0;

uniform bool InvertHideOnRMB <
  ui_category = CATEGORY_GENERAL;
  ui_label = "反转按右键隐藏";
  ui_tooltip = "反转“按右键隐藏”的行为。";
> = 0;

/**
 * Composite Xhair Settings
 */

uniform int DotType <
  ui_category = CATEGORY_XHAIR_COMPOSITE;
  ui_type = "combo";
  ui_items = "圆形\0方形\0禁用\0";
  ui_label = "使用点";
  ui_tooltip = "控制是否在选定的准心上方渲染一个点。";
> = 2;

uniform float3 DotColor <
  ui_category = CATEGORY_XHAIR_COMPOSITE;
  ui_type = "color";
  ui_label = "点颜色";
> = float3(0.0, 1.0, 0.0);

uniform int DotSize <
  ui_category = CATEGORY_XHAIR_COMPOSITE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 1; ui_max = 30;
  ui_label = "点大小";
> = 1;

uniform float DotOpacity <
  ui_category = CATEGORY_XHAIR_COMPOSITE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_label = "点透明度";
> = 1.0;

/**
 * Cross Xhair Settings
 */

uniform float3 CrossColor <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_type = "颜色";
  ui_label = "颜色";
> = float3(0.0, 1.0, 0.0);

uniform int CrossLength <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 1; ui_max = 100;
  ui_label = "长度";
> = 6;

uniform int CrossThickness <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0; ui_max = 10;
  ui_label = "粗细";
> = 1;

uniform int CrossGap <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0; ui_max = 10;
  ui_label = "间隙";
> = 3;


/**
 * 十字准心轮廓设置
 */

uniform bool CrossOutlineEnabled <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_label = "启用轮廓";
> = 1;

uniform bool CrossOutlineGlowEnabled <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_label = "启用轮廓发光";
> = true;

uniform float3 CrossOutlineColor <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_type = "颜色";
  ui_label = "轮廓颜色";
> = float3(0.0, 0.0, 0.0);

uniform float CrossOutlineOpacity <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_label = "轮廓透明度";
> = 1.0;

uniform int f_crossOutlineSharpness <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0; ui_max = (MAX_CROSS_OUTLINE_THICKNESS);
  ui_step = 1;
  ui_label = "轮廓锐度";
  ui_tooltip = "控制在准心周围渲染多少像素以100％不透明（推荐：1或0）。";
> = 1;
#define CrossOutlineSharpness (max(f_crossOutlineSharpness, 0))

uniform int f_crossOutlineGlow <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0; ui_max = MAX_CROSS_OUTLINE_THICKNESS;
  ui_step = 1;
  ui_label = "轮廓发光";
  ui_tooltip = "控制在锐利轮廓周围渲染多少发光轮廓像素。";
> = 2;
#define CrossOutlineGlow (max(f_crossOutlineGlow, 0))

uniform float CrossOutlineGlowOpacity <
  ui_category = CATEGORY_XHAIR_CROSS;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "轮廓发光透明度";
> = 0.15;

/**
 * Circle Xhair Settings
 */

uniform float3 CircleColor <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = "color";
  ui_label = "颜色";
> = float3(0.0, 1.0, 0.0);

uniform float CircleThickness <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = "drag";
  ui_min = 0.0; ui_max = 20.0;
  ui_label = "粗细";
> = 2.0;

uniform float CircleGapRadius <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 20.0;
  ui_label = "间隙半径";
> = 4.0;

/**
 * Circle Xhair Outline Settings
 */

uniform bool CircleOutlineEnabled <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_label = "启用轮廓";
> = 1;

uniform bool CircleOutlineGlowEnabled <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_label = "启用轮廓发光";
> = true;


uniform float3 CircleOutlineColor <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = "color";
  ui_label = "轮廓颜色";
> = float3(0.0, 0.0, 0.0);


uniform float CircleOutlineOpacity <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = UI_TYPE_SLIDER;
  ui_min = 0.0; ui_max = 1.0;
  ui_label = "轮廓透明度";
> = 1.0;

uniform float f_circleOuterOutlineSharpness <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = "drag";
  ui_min = 0; ui_max = MAX_CIRCLE_OUTLINE_THICKNESS;
  ui_step = 0.01;
  ui_label = "外轮廓锐度";
  ui_tooltip = "控制在圆形外轮廓像素（圆形外部）中应渲染多少像素以100％不透明。";
> = 1.0;
#define CircleOuterOutlineSharpness (min(max(f_circleOuterOutlineSharpness, 0), CircleOuterOutlineGlow))

uniform float f_circleOuterOutlineGlow <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = "drag";
  ui_min = 0.0; ui_max = MAX_CIRCLE_OUTLINE_THICKNESS;
  ui_step = 0.01;
  ui_label = "外轮廓发光";
  ui_tooltip = "控制在锐利轮廓外渲染多少发光轮廓像素（圆形外部）。";
> = 2.0;
#define CircleOuterOutlineGlow (max(f_circleOuterOutlineGlow, 0))

uniform float CircleOuterOutlineGlowOpacity <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = "drag";
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "外轮廓发光透明度";
> = 0.15;

uniform float f_circleInnerOutlineSharpness <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = "drag";
  ui_min = 0; ui_max = MAX_CIRCLE_OUTLINE_THICKNESS;
  ui_step = 0.01;
  ui_label = "内轮廓锐度";
  ui_tooltip = "控制在圆形内轮廓像素（圆形内部）中应渲染多少像素以100％不透明。";
> = 1.0;
#define CircleInnerOutlineSharpness (min(max(f_circleInnerOutlineSharpness, 0), CircleInnerOutlineGlow))

uniform float f_circleInnerOutlineGlow <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = "drag";
  ui_min = 0.0; ui_max = MAX_CIRCLE_OUTLINE_THICKNESS;
  ui_step = 0.01;
  ui_label = "内轮廓发光";
  ui_tooltip = "控制在锐利轮廓内渲染多少发光轮廓像素（圆形内部）。";
> = 2.0;
#define CircleInnerOutlineGlow (max(f_circleInnerOutlineGlow, 0))

uniform float CircleInnerOutlineGlowOpacity <
  ui_category = CATEGORY_XHAIR_CIRCLE;
  ui_type = "drag";
  ui_min = 0.0; ui_max = 1.0;
  ui_step = 0.005;
  ui_label = "内轮廓发光透明度";
> = 0.15;

/**
 * RMB States
 */

uniform bool rightMouseDown <
  source = "mousebutton";
  keycode = 1;
  toggle = false;
>;

uniform bool rightMouseToggle <
  source = "mousebutton";
  keycode = 1;
  mode = "toggle";
  toggle = false;
>;

/**
 * Helpers
 */

#define BareCrossLength (CrossLength + CrossGap)

#define EULER (0.57721566490153286061)

#define XOR(a, b) ((a) && !(b) || !(a) && (b))

#define CROSS_OUTLINE_GLOW_RADIAL(intensity) (lerp(0.0, CrossOutlineGlowOpacity, intensity))
// http://cubic-bezier.com/#.06,1.2,0,.9
#define CROSS_OUTLINE_GLOW_BEZIER_CUBIC_PRESET_1(intensity) (cubicBezier(float2(.06, 1.2), float2(0, .9), intensity))

#ifndef CROSS_OUTLINE_GLOW_CURVE
  #define CROSS_OUTLINE_GLOW_CURVE CROSS_OUTLINE_GLOW_BEZIER_CUBIC_PRESET_1
#endif

#define CROSS_OUTLINE_GLOW(intensity) (CrossOutlineGlowEnabled ? saturate(CROSS_OUTLINE_GLOW_CURVE(intensity) * CrossOutlineGlowOpacity) : 0.0)

#define CIRCLE_OUTER_OUTLINE_GLOW(intensity) (CircleOutlineGlowEnabled ? lerp(CircleOuterOutlineGlowOpacity, 0.0, intensity) : 0.0)
#define CIRCLE_INNER_OUTLINE_GLOW(intensity) (CircleOutlineGlowEnabled ? lerp(CircleInnerOutlineGlowOpacity, 0.0, intensity) : 0.0)

float2 cubicBezier(float2 p1, float2 p2, float i) {
  float x = pow(1 - i, 3) * 0 +
    3 * i * pow(1 - i, 2) * p1.x +
    3 * pow(i, 2) * (1 - i) * p2.x +
    pow(i, 3) * 1;
  float y = pow(1 - i, 3) * 0 +
    3 * i * pow(1 - i, 2) * p1.y +
    3 * pow(i, 2) * (1 - i) * p2.y +
    pow(i, 3) * 1;
  return float2(x, y);
}

#define invertSaturate(x) (1.0 - saturate((x)))
#define manhattanDistance(p1, p2) (abs(p1.x - p2.x) + abs(p1.y - p2.y))

#ifdef __DEBUG__
uniform int random1 < source = "random"; min = 0; max = 255; >;
uniform int random2 < source = "random"; min = 0; max = 255; >;
uniform int random3 < source = "random"; min = 0; max = 255; >;
#endif

/*
 * Xhair Shader
 */

void drawCircleXhair(float distCenter, out float4 draw, inout float drawOpacity) {
  draw = float4(CircleColor, 1.0);
  drawOpacity = XhairOpacity;

  bool isXhairPixel = int(round(
    max(CircleThickness - abs(distCenter - (CircleGapRadius + CircleThickness / 2.0)), 0) / CircleThickness
  )) == 1;

  if (!isXhairPixel) {
    drawOpacity = 0;
  }

  if (CircleOutlineEnabled && !isXhairPixel) {

    float bareCrosshairInnerRadius = CircleGapRadius;
    float bareCrosshairOuterRadius = CircleGapRadius + CircleThickness;

    float outerOutlineFullRadius = bareCrosshairOuterRadius + CircleOuterOutlineGlow;
    float outerOutlineSharpRadius = bareCrosshairOuterRadius + CircleOuterOutlineSharpness;

    float innerOutlineFullRadius = bareCrosshairInnerRadius - CircleInnerOutlineGlow;
    float innerOutlineSharpRadius = bareCrosshairInnerRadius - CircleInnerOutlineSharpness;

    draw = float4(CircleOutlineColor, 1.0);

    if (distCenter < outerOutlineFullRadius && distCenter > CircleGapRadius) {
      float glowIntensity = invertSaturate((outerOutlineFullRadius - distCenter) / (CircleOuterOutlineGlow - CircleOuterOutlineSharpness));
      drawOpacity = distCenter < outerOutlineSharpRadius
        ? CircleOutlineOpacity * XhairOpacity
        : CIRCLE_OUTER_OUTLINE_GLOW(glowIntensity) * XhairOpacity;
    } else if (distCenter > innerOutlineFullRadius && distCenter < bareCrosshairInnerRadius) {
      float glowIntensity = saturate((innerOutlineFullRadius - distCenter) / (CircleInnerOutlineGlow - CircleInnerOutlineSharpness));
      drawOpacity = distCenter > innerOutlineSharpRadius
        ? CircleOutlineOpacity * XhairOpacity
        : CIRCLE_INNER_OUTLINE_GLOW(glowIntensity) * XhairOpacity;
    }
  }
}

void drawCrossXhair(int distX, int distY, out float4 draw, inout float drawOpacity) {
  int absDistX = abs(distX);
  int absDistY = abs(distY);

  draw = float4(CrossColor, 1.0);
  drawOpacity = XhairOpacity;

  if (absDistX < absDistY) { // Vertical pixel

    bool isXhairPixel = int(round(min(
      max((CrossThickness * 2.0) - absDistX, 0) / max(CrossThickness * 2.0, 1),
      max(BareCrossLength - absDistY, 0)
    ))) == 1;

    // T-shape: don't render pixels above the gap
    if (XhairType == 2 && distY >= CrossGap) {
      drawOpacity = 0;
      return;
    }

    // Check if we should (not) render a xhair pixel
    if (absDistY < CrossGap || !isXhairPixel) {
      drawOpacity = 0;
    }

    // Check if we should render an outline pixel
    if (CrossOutlineEnabled && !isXhairPixel && absDistY >= CrossGap) {

      // Pixel distance from the bare crosshair (w/o the outline)
      int bareCrossDistX = absDistX - CrossThickness;
      int bareCrossDistY = absDistY - BareCrossLength;

      // Pixel distance from the sharp outline
      int sharpOutlineDistX = bareCrossDistX - CrossOutlineSharpness;
      int sharpOutlineDistY = bareCrossDistY - CrossOutlineSharpness;

      draw = float4(CrossOutlineColor, 1.0);

      #ifdef __DEBUG__
      if (sharpOutlineDistX == 0 && sharpOutlineDistY == 0) {
        draw = float4(random1/255.0, random2/255.0, random3/255.0, 1);
        return draw;
      }
      #endif

      float2 relativePos = float2(max(bareCrossDistX, 0), max(bareCrossDistY, 0));
      float dist = distance(relativePos, float2(0, 0));
      if (dist < CrossOutlineSharpness) {
        drawOpacity = XhairOpacity;
      } else if (dist < (CrossOutlineSharpness + CrossOutlineGlow)) {
        float glowIntensity = saturate(1.0 - ((dist - CrossOutlineSharpness) / float(CrossOutlineGlow)));
        drawOpacity = CROSS_OUTLINE_GLOW(glowIntensity) * XhairOpacity;
      }

      drawOpacity *= CrossOutlineOpacity * XhairOpacity;
    }

  } else { // Horizontal pixel

    bool isXhairPixel = int(round(min(
      max((CrossThickness * 2.0) - absDistY, 0) / max(CrossThickness * 2.0, 1),
      max(BareCrossLength - absDistX, 0)
    ))) == 1;

    // Check if we should (not) render a xhair pixel
    if (absDistX < CrossGap || !isXhairPixel) {
      drawOpacity = 0;
    }

    // Check if we should render an outline pixel
    if (CrossOutlineEnabled && !isXhairPixel && absDistX >= CrossGap) {

      // Pixel distance from the bare crosshair (w/o the outline)
      int bareCrossDistX = absDistX - BareCrossLength;
      int bareCrossDistY = absDistY - CrossThickness;

      // Pixel distance from the sharp outline
      int sharpOutlineDistX = bareCrossDistX - CrossOutlineSharpness;
      int sharpOutlineDistY = bareCrossDistY - CrossOutlineSharpness;

      draw = float4(CrossOutlineColor, 1.0);

      #ifdef __DEBUG__
      if (sharpOutlineDistX == 0 && sharpOutlineDistY == 0) {
        draw = float4(random1/255.0, random2/255.0, random3/255.0, 1);
        return draw;
      }
      #endif

      float2 relativePos = float2(max(bareCrossDistX, 0), max(bareCrossDistY, 0));
      float dist = distance(relativePos, float2(0, 0));
      if (dist < CrossOutlineSharpness) {
        drawOpacity = XhairOpacity;
      } else if (dist < (CrossOutlineSharpness + CrossOutlineGlow)) {
        float glowIntensity = saturate(1.0 - ((dist - CrossOutlineSharpness) / float(CrossOutlineGlow)));
        drawOpacity = CROSS_OUTLINE_GLOW(glowIntensity) * XhairOpacity;
      }

      drawOpacity *= CrossOutlineOpacity * XhairOpacity;
    }

  }
}

float4 PS_Xhair(float4 pos : SV_Position, float2 texcoord : TEXCOORD) : SV_Target {
  float4 drawBackground = tex2D(ReShade::BackBuffer, texcoord);

  // Don't render if RMB hiding is activated
  if (XOR(HideOnRMB == 0 && rightMouseDown || HideOnRMB == 1 && rightMouseToggle, InvertHideOnRMB)) {
    return drawBackground;
  }

  float2 center = float2((BUFFER_WIDTH / 2) + OffsetX, (BUFFER_HEIGHT / 2) + OffsetY);

  int distX = center.x - pos.x;
  int distY = center.y - pos.y;
  float distCenter = distance(center, pos);

  float4 draw;
  float drawOpacity = 0;

  // Circle
  if (XhairType == 1) {
    drawCircleXhair(distCenter, draw, drawOpacity);
  // Cross or T-shaped
  } else if (XhairType == 0 || XhairType == 2) {
    drawCrossXhair(distX, distY, draw, drawOpacity);
  }

  if (
    // Dot: Circle
    (DotType == 0 && distCenter <= DotSize) ||
    // Dot: Square
    (DotType == 1 && abs(distX) <= (DotSize - 1) && abs(distY) <= (DotSize - 1))
  ) {
    draw = float4(DotColor, 1.0);
    drawOpacity = DotOpacity;
  }

  return lerp(drawBackground, draw, drawOpacity);
}

technique xhair {
  pass HudPass {
    VertexShader = PostProcessVS;
    PixelShader = PS_Xhair;
  }
}
