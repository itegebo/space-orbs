#lang racket
(require pict3d rackunit pict3d/universe mzlib/string "structures.rkt" "variables.rkt")
(provide rotate-around-dir rotation-to-dir dir-to-rotation)

;;rotates to-rotate around around
;;takes two dir and an angle -> one dir
(define (rotate-around-dir around to-rotate ang)
  (rotate-around-coordinates
   (dir-dx to-rotate)
   (dir-dy to-rotate)
   (dir-dz to-rotate)
   (dir-dx around)
   (dir-dy around)
   (dir-dz around)
   ang))

;;rotates point x y z around origin and u v w
;;u v w has to be a unit vector
(define (rotate-around-coordinates x y z u v w deg-ang)
  (define ang (/ (* deg-ang pi) 180))
  (define cang (cos ang))
  (define sang (sin ang))
  (define (base g h)
    (+
     (*
      (- g)
      (- 0 (* u x) (* v y) (* w z))
      (- 1 cang))
     (* h cang)))
  (dir
   (+
    (base u x)
    (*
     (- (* v z) (* w y))
     sang))
   (+
    (base v y)
    (*
     (- (* w x) (* u z))
     sang))
   (+
    (base w z)
    (*
     (- (* u y) (* v x))
     sang)))) ;;FIXME dir: expected rational coordinates; given +inf.0 +inf.0 +inf.0 bug

(module+ test (check-equal?
               (round-dir (rotate-around-coordinates 1 0 0 0 0 1 180))
               (dir -1 0 0)))
(module+ test (check-equal?
               (round-dir (rotate-around-coordinates 0 1 0 1 0 0 90))
               (dir 0 0 1)))

;;takes dir and angle -> dir
(define (rotation-to-dir dir ang)
  (define-values (yaw pitch) (dir->angles dir))
  (rotate-around-dir dir (angles->dir yaw (+ pitch 90)) ang))

(module+ test (rotation-to-dir +x 0) -z)

(define (dir-to-rotation basedir rotdir)
  (define downdir (rotation-to-dir basedir 0))
  (define leftdir (rotation-to-dir basedir 90))
  (define a
    (*
     (asin (min 1.0 (/ (dir-dist (dir- downdir rotdir)) 2)))
     2
     (/ 180 pi)))
  (cond
    [(< (dir-dist (dir- leftdir rotdir)) (sqrt 2))
     a]
    [(= (- 360 a) 360)
     0]
    [else
     (- 360 a)]))