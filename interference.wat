
(import "math" "sin" (func $sin (param f32) (result f32)))
(import "math" "cos" (func $cos (param f32) (result f32)))

(memory (export "mem") 4)

(func $increment (param $value i32) (result i32)
  (i32.add 
    (get_local $value)
    (i32.const 1)
  )
)

(func $offsetFromCoordinate (param $x i32) (param $y i32) (result i32)
  (i32.add
    (i32.mul
      (i32.const 1280) ;; 320 * 4
      (get_local $y))
    (i32.mul
      (i32.const 4)
      (get_local $x))
  )
)

(func $setPixel (param $x i32) (param $y i32) (param $value i32)
  (i32.store
    (call $offsetFromCoordinate
      (get_local $x)
      (get_local $y)
    )
    (i32.or
      (i32.shl
        (get_local $value)
        (i32.const 24)
      )
      (i32.shl
        (get_local $value)
        (i32.const 8)
      )
    )
  )
)

(func $distance (param $x1 i32) (param $y1 i32) (param $x2 f32) (param $y2 f32) (result f32)
  (local $dx f32)
  (local $dy f32)

  (set_local $dx
    (f32.sub
      (f32.convert_s/i32 (get_local $x1))
      (get_local $x2)
    )
  )

  (set_local $dy
    (f32.sub
      (f32.convert_s/i32 (get_local $y1))
      (get_local $y2)
    )
  )

  (f32.sqrt
    (f32.add
      (f32.mul
        (get_local $dx)
        (get_local $dx)
      )
      (f32.mul
        (get_local $dy)
        (get_local $dy)
      )
    )
  )
)

(func $run (param $tick f32)
  (local $x i32)
  (local $y i32)
  (local $cx1 f32)
  (local $cy1 f32)
  (local $cx2 f32)
  (local $cy2 f32)

  (set_local $cx1 
    (f32.add
      (f32.mul
        (f32.add
          (call $sin
            (f32.mul (get_local $tick) (f32.const 2))
          )
          (call $sin
            (get_local $tick)
          )
        )
        (f32.const 50)
      )
      (f32.const 160)
    )
  )

  (set_local $cy1 
    (f32.add
      (f32.mul
        (call $cos
          (get_local $tick)
        )
        (f32.const 40)
      )
      (f32.const 100)
    )
  )

  (set_local $cx2
    (f32.add
      (f32.mul
        (f32.add
          (call $sin
            (f32.mul (get_local $tick) (f32.const 4))
          )
          (call $sin
            (f32.add (get_local $tick) (f32.const 1.2))
          )
        )
        (f32.const 50)
      )
      (f32.const 160)
    )
  )

  (set_local $cy2 
    (f32.add
      (f32.mul
        (f32.add
          (call $sin
            (f32.mul (get_local $tick) (f32.const 3))
          )
          (call $cos
            (f32.add (get_local $tick) (f32.const 0.1))
          )
        )
        (f32.const 40)
      )
      (f32.const 100)
    )
  )

  (set_local $y (i32.const 0))
  
  (block 
    (loop 

      (set_local $x (i32.const 0))

      (block 
        (loop 

          (call $setPixel
            (get_local $x)
            (get_local $y)

            (i32.trunc_s/f32
              (f32.mul
                (f32.abs
                  (f32.add
                    (call $sin
                      (f32.mul
                        (call $distance
                          (get_local $x)
                          (get_local $y)
                          (get_local $cx1)
                          (get_local $cy1)
                        )
                        (f32.const 0.15)
                      )
                    )
                    (call $sin
                      (f32.mul
                        (call $distance
                          (get_local $x)
                          (get_local $y)
                          (get_local $cx2)
                          (get_local $cy2)
                        )
                        (f32.const 0.15)
                      )
                    )
                  )
                )
                (f32.const 120)
              )
            )

          )

          (set_local $x (call $increment (get_local $x)))
          (br_if 1 (i32.eq (get_local $x) (i32.const 320)))
          (br 0)
        )
      )
      
      (set_local $y (call $increment (get_local $y)))
      (br_if 1 (i32.eq (get_local $y) (i32.const 200)))
      (br 0)
    )
  )
)

(export "run" (func $run))
