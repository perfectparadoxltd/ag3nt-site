// AG3NT — genera og.png (1200x630) con la estética Monolith + red de agentes.
// Uso: swift make_og.swift
import AppKit

let W: CGFloat = 1200, H: CGFloat = 630
let img = NSImage(size: NSSize(width: W, height: H))
img.lockFocus()

func hex(_ s: String) -> NSColor {
    let n = UInt64(s, radix: 16) ?? 0
    return NSColor(calibratedRed: CGFloat((n>>16)&0xff)/255, green: CGFloat((n>>8)&0xff)/255, blue: CGFloat(n&0xff)/255, alpha: 1)
}
// Fondo void
hex("0E0E0E").setFill(); NSRect(x:0,y:0,width:W,height:H).fill()

// Red de agentes (constelación) en la mitad derecha
let cols = ["7F77DD","1D9E75","D85A30","D4537E","BA7517","85B7EB"].map { hex($0) }
var pts: [(NSPoint, NSColor)] = []
var seed: UInt64 = 88
func rnd() -> CGFloat { seed = seed &* 6364136223846793005 &+ 1442695040888963407; return CGFloat((seed >> 33) % 10000) / 10000 }
for _ in 0..<26 { pts.append((NSPoint(x: 620 + rnd()*540, y: 40 + rnd()*560), cols[Int(rnd()*6)])) }
// líneas
for i in 0..<pts.count { for j in (i+1)..<pts.count {
    let a=pts[i].0, b=pts[j].0, d=hypot(a.x-b.x,a.y-b.y)
    if d<190 { let p=NSBezierPath(); p.move(to:a); p.line(to:b); p.lineWidth=1
        pts[i].1.withAlphaComponent((1-d/190)*0.35).setStroke(); p.stroke() } } }
// nodos
for (p,c) in pts { c.setFill(); NSBezierPath(ovalIn: NSRect(x:p.x-4,y:p.y-4,width:8,height:8)).fill() }

func draw(_ s: String, _ x: CGFloat, _ y: CGFloat, _ size: CGFloat, _ color: NSColor, weight: NSFont.Weight = .semibold, mono: Bool = false) {
    let font = mono ? NSFont.monospacedSystemFont(ofSize: size, weight: weight) : NSFont.systemFont(ofSize: size, weight: weight)
    let attrs: [NSAttributedString.Key: Any] = [.font: font, .foregroundColor: color]
    NSString(string: s).draw(at: NSPoint(x: x, y: y), withAttributes: attrs)
}

// Texto (origen abajo-izq en AppKit)
draw("AG3NT", 80, 470, 44, .white, weight: .bold)
draw("Your AI team.", 80, 320, 78, .white, weight: .bold)
draw("On your Mac.", 80, 230, 78, hex("919191"), weight: .bold)
draw("On-device · coordinated · one-time", 80, 150, 24, hex("E5E2E1"), weight: .regular, mono: true)
draw("perfectparadox.co.uk", 80, 70, 18, hex("919191"), weight: .regular, mono: true)

img.unlockFocus()
let tiff = img.tiffRepresentation!
let png = NSBitmapImageRep(data: tiff)!.representation(using: .png, properties: [:])!
try! png.write(to: URL(fileURLWithPath: "og.png"))
print("✅ og.png")
