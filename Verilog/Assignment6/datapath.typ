#set page(
  paper: "a4",
  flipped: true,
  margin: (x: 1.2cm, top: 0.8cm, bottom: 0.8cm),
)
#set text(font: "Liberation Sans", size: 9pt)

#import "@preview/cetz:0.3.4"

#align(center)[
  #text(size: 15pt, weight: "bold", fill: rgb("#1e3a8a"))[Datapath & Control Architecture: 4-bit Sequential Booth Multiplier] \
  #v(-2pt)
  #text(size: 9pt, fill: rgb("#4b5563"))[Iterative Signed 2's-Complement Hardware Architecture (IIT Kharagpur COA Lab)]
]

#v(2pt)

#align(center)[
#cetz.canvas({
  import cetz.draw: *

  // Color Palette & Styles
  let reg-fill = rgb("#eff6ff")
  let reg-stroke = 1.2pt + rgb("#2563eb")
  let alu-fill = rgb("#fef2f2")
  let alu-stroke = 1.2pt + rgb("#dc2626")
  let mux-fill = rgb("#fffbeb")
  let mux-stroke = 1.2pt + rgb("#d97706")
  let ctrl-fill = rgb("#faf5ff")
  let ctrl-stroke = 1.2pt + rgb("#9333ea")
  let shift-fill = rgb("#ecfdf5")
  let shift-stroke = 1.2pt + rgb("#059669")

  let bus-stroke = 1.2pt + rgb("#1e293b")
  let ctrl-stroke = 1pt + rgb("#7c3aed")
  let clk-stroke = 0.9pt + rgb("#0d9488")
  let out-stroke = 1.8pt + rgb("#b91c1c")

  // ==========================================
  // 1. LEFT SIDE: CLOCK & CONTROL UNIT
  // ==========================================
  rect((-13.0, 3.8), (-10.2, 2.5), fill: ctrl-fill, stroke: ctrl-stroke, radius: 4pt, name: "clk_div")
  content("clk_div", align(center)[*Clock Divider*\ #text(size: 7.5pt)[100 MHz $arrow.r$ slow_clk]])

  rect((-13.0, 1.8), (-10.2, -0.4), fill: ctrl-fill, stroke: ctrl-stroke, radius: 4pt, name: "ctrl")
  content("ctrl", align(center)[*Control Logic*\ #text(size: 7.5pt)[
    State / Done Logic\
    Iter Counter: `count[2:0]`\
    4 Iterations Controller
  ]])

  // Clock & Reset Inputs
  line((-14.2, 3.15), (-13.0, 3.15), stroke: clk-stroke, mark: (end: ">"))
  content((-14.3, 3.15), [clk], anchor: "east")

  line((-14.2, 1.1), (-13.0, 1.1), stroke: ctrl-stroke, mark: (end: ">"))
  content((-14.3, 1.1), [start, reset], anchor: "east")

  line((-11.6, 2.5), (-11.6, 1.8), stroke: clk-stroke, mark: (end: ">"))
  content((-11.4, 2.15), [slow_clk], anchor: "west")

  // Control signals to Datapath
  line((-10.2, 0.7), (-9.0, 0.7), stroke: ctrl-stroke, mark: (end: ">"))
  content((-9.6, 0.95), [Init / Enable], anchor: "south")

  // ==========================================
  // 2. MAIN REGISTERS (M, A, Q, Q_-1)
  // ==========================================
  // Reg M (5-bit)
  rect((-9.0, 4.2), (-6.2, 3.0), fill: reg-fill, stroke: reg-stroke, radius: 4pt, name: "reg_m")
  content("reg_m", align(center)[*Register M (5b)*\ #text(size: 7.5pt)[Sign-ext Multiplicand]])

  // Reg A (5-bit)
  rect((-4.8, 4.2), (-2.0, 3.0), fill: reg-fill, stroke: reg-stroke, radius: 4pt, name: "reg_a")
  content("reg_a", align(center)[*Register A (5b)*\ #text(size: 7.5pt)[Accumulator]])

  // Reg Q (4-bit)
  rect((-0.6, 4.2), (2.2, 3.0), fill: reg-fill, stroke: reg-stroke, radius: 4pt, name: "reg_q")
  content("reg_q", align(center)[*Register Q (4b)*\ #text(size: 7.5pt)[Multiplier]])

  // Reg Q_-1 (1-bit)
  rect((3.4, 4.2), (5.6, 3.0), fill: reg-fill, stroke: reg-stroke, radius: 4pt, name: "reg_q_1")
  content("reg_q_1", align(center)[*Reg $Q_(-1)$ (1b)*\ #text(size: 7.5pt)[Previous LSB]])

  // External Data Inputs to Registers
  line((-7.6, 5.2), (-7.6, 4.2), stroke: bus-stroke, mark: (end: ">"))
  content((-7.6, 5.3), [multiplicand[3:0] #text(size: 7.5pt)[(sign-extended)]], anchor: "south")

  line((0.8, 5.2), (0.8, 4.2), stroke: bus-stroke, mark: (end: ">"))
  content((0.8, 5.3), [multiplier[3:0]], anchor: "south")

  // ==========================================
  // 3. COMBINATIONAL LOGIC: ALU & BOOTH DECISION
  // ==========================================
  // 5-bit ALU
  rect((-7.0, 1.4), (-2.2, 0.0), fill: alu-fill, stroke: alu-stroke, radius: 4pt, name: "alu")
  content("alu", align(center)[*5-bit Adder / Subtractor (ALU)*\ #text(size: 7.5pt)[$A + M$, $A - M$, or Pass $A$]])

  // Booth Decision Logic
  rect((0.2, 1.4), (4.8, 0.0), fill: ctrl-fill, stroke: ctrl-stroke, radius: 4pt, name: "booth_dec")
  content("booth_dec", align(center)[*Booth Decision Logic*\ #text(size: 7.5pt)[Evaluates 2-bit window ${Q_0, Q_(-1)}$]])

  // Routing into ALU
  line((-7.6, 3.0), (-7.6, 1.9), (-5.8, 1.9), (-5.8, 1.4), stroke: bus-stroke, mark: (end: ">"))
  content((-7.6, 2.4), [M[4:0]], anchor: "east")

  line((-3.4, 3.0), (-3.4, 1.4), stroke: bus-stroke, mark: (end: ">"))
  content((-3.3, 2.2), [A[4:0]], anchor: "west")

  // Routing into Booth Decision
  line((0.8, 3.0), (0.8, 1.8), (1.6, 1.8), (1.6, 1.4), stroke: bus-stroke, mark: (end: ">"))
  content((0.7, 2.4), [Q[0]], anchor: "east")

  line((4.5, 3.0), (4.5, 1.8), (3.6, 1.8), (3.6, 1.4), stroke: bus-stroke, mark: (end: ">"))
  content((4.6, 2.4), [$Q_(-1)$], anchor: "west")

  // Control from Booth Decision to ALU
  line((0.2, 0.7), (-2.2, 0.7), stroke: ctrl-stroke, mark: (end: ">"))
  content((-1.0, 0.95), [#text(size: 7.5pt)[ALU Op Control]], anchor: "south")

  // ==========================================
  // 4. ARITHMETIC RIGHT SHIFT ROUTING (10-bit)
  // ==========================================
  rect((-6.5, -1.0), (5.5, -2.4), fill: shift-fill, stroke: shift-stroke, radius: 4pt, name: "shifter")
  content("shifter", align(center)[
    #text(weight: "bold", size: 8.5pt, fill: rgb("#065f46"))[10-bit Arithmetic Right Shift Routing]\
    #v(1pt)
    #text(size: 7.5pt)[${A, Q, Q_(-1)} arrow.l {A_"next"[4], A_"next"[4:1], A_"next"[0], Q[3:1], Q[0]}$] \
    #text(size: 6.8pt, fill: rgb("#047857"))[Preserves MSB sign bit $A_"next"[4]$ during 1-bit right shift]
  ])

  // ALU output to Shifter
  line((-4.6, 0.0), (-4.6, -1.0), stroke: bus-stroke, mark: (end: ">"))
  content((-4.5, -0.5), [$A_"next"[4:0]$], anchor: "west")

  // Q[3:0] into Shifter (routed around Booth Decision)
  line((2.0, 3.0), (2.0, 2.0), (5.1, 2.0), (5.1, -1.0), stroke: bus-stroke, mark: (end: ">"))
  content((5.2, 0.5), [Q[3:0]], anchor: "west")

  // Feedback to Reg A (routed safely around ALU on the left)
  line((-6.5, -1.7), (-9.6, -1.7), (-9.6, 4.8), (-3.4, 4.8), (-3.4, 4.2), stroke: bus-stroke, mark: (end: ">"))
  content((-9.7, 1.5), [#text(size: 7.5pt)[$A_"shift"$ (5b)]], anchor: "east")

  // Feedback to Reg Q (routed safely on the right)
  line((5.5, -1.5), (6.8, -1.5), (6.8, 4.8), (0.8, 4.8), (0.8, 4.2), stroke: bus-stroke, mark: (end: ">"))
  content((6.9, 1.5), [#text(size: 7.5pt)[$Q_"shift"$ (4b)]], anchor: "west")

  // Feedback to Reg Q_-1 (capturing Q[0])
  line((5.5, -1.9), (7.8, -1.9), (7.8, 4.8), (4.5, 4.8), (4.5, 4.2), stroke: bus-stroke, mark: (end: ">"))
  content((7.9, 1.5), [#text(size: 7.5pt)[Q[0]]], anchor: "west")

  // ==========================================
  // 5. OUTPUT DISPLAY MULTIPLEXER (16-bit)
  // ==========================================
  rect((-6.5, -3.2), (6.5, -4.5), fill: mux-fill, stroke: mux-stroke, radius: 4pt, name: "mux")
  content("mux", align(center)[
    #text(weight: "bold", size: 8.5pt, fill: rgb("#b45309"))[16-bit LED Output Multiplexer]\
    #v(1pt)
    #text(size: 7.5pt)[
      `display_sel = 0` : Internal State `${"2'b00", "done", "count"[2:0], Q_(-1), Q[3:0], A[4:0]}` \
      `display_sel = 1` : Final Result `${"7'b0000000", "done", "Product"[7:0]}` where $"Product" = {A[3:0], Q[3:0]}$
    ]
  ])

  // Product taps to Mux
  line((-3.4, 3.0), (-3.4, -3.2), stroke: bus-stroke, mark: (end: ">"))
  content((-3.3, -2.7), [A[3:0]], anchor: "west")

  line((0.8, 3.0), (0.8, -3.2), stroke: bus-stroke, mark: (end: ">"))
  content((0.9, -2.7), [Q[3:0]], anchor: "west")

  // Select signal
  line((-8.0, -3.85), (-6.5, -3.85), stroke: ctrl-stroke, mark: (end: ">"))
  content((-8.1, -3.85), [display_sel], anchor: "east")

  // Final LED Output
  line((0.0, -4.5), (0.0, -5.1), stroke: out-stroke, mark: (end: ">"))
  content((0.0, -5.2), [*led[15:0] (16 FPGA Board LEDs)*], anchor: "north")



})
]

#v(2pt)

#grid(
  columns: (1fr, 1.1fr),
  gutter: 12pt,
  [
    #block(
      fill: rgb("#f8fafc"),
      stroke: 0.8pt + rgb("#cbd5e1"),
      inset: (x: 8pt, y: 5pt),
      radius: 4pt,
      width: 100%,
      [
        #text(weight: "bold", fill: rgb("#1e3a8a"), size: 8.5pt)[Booth ALU Operation Table]
        #v(2pt)
        #table(
          columns: (1fr, 1.8fr, 2.8fr),
          align: (center, center, left),
          inset: 3.5pt,
          table.header([*$\{Q_0, Q_(-1)\}$*], [*ALU Action*], [*Operation Details*]),
          [`00`], [No Operation], [Pass Accumulator ($A_"next" = A$)],
          [`01`], [$A arrow.l A + M$], [Add multiplicand to Accumulator],
          [`10`], [$A arrow.l A - M$], [Subtract multiplicand ($A + tilde(M) + 1$)],
          [`11`], [No Operation], [Pass Accumulator ($A_"next" = A$)],
        )
      ]
    )
  ],
  [
    #block(
      fill: rgb("#f8fafc"),
      stroke: 0.8pt + rgb("#cbd5e1"),
      inset: (x: 8pt, y: 5pt),
      radius: 4pt,
      width: 100%,
      [
        #text(weight: "bold", fill: rgb("#1e3a8a"), size: 8.5pt)[LED Display Selection (`display_sel`)]
        #v(2pt)
        #table(
          columns: (1fr, 1.4fr, 3.8fr),
          align: (center, center, left),
          inset: 3.5pt,
          table.header([*`display_sel`*], [*Mode*], [*LED Vector Output (`led[15:0]`)*]),
          [`0`], [Internal State], [`{ 2'b00, done, count[2:0], Q_-1, Q[3:0], A[4:0] }`],
          [`1`], [Final Result], [`{ 7'b0000000, done, product[7:0] }` ($"product" = {A[3:0], Q[3:0]}$)],
        )
      ]
    )
  ]
)
