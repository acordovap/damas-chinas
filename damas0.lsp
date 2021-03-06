; Definicion de nodo;
; ( 0       1              2      3      4     5 )
; ( no_node no_parent_node pieces (movs) level f )
; Donde:
;   no_node =  no. del nodo creado
;   no_parent_node =  no. del nodo padre
;   pieces = las piezas, lista
;   (movs) = lista de movimientos del ultimo edo. al presente ( mov1 [mov2 ... ] )
;   level = nivel del nodo en el arbol
;   f = la funcion de evaluacion para nodos hoja o alfa/beta para el resto de los nodos
;         ( 0       1       2        3        4     )
;   mov = ( qOrigen rOrigen qDestino rDestino color )
; color = 0-blanco, 1-negro
;
; Funcion para leer el archivo que contiene el estado inicial las piezas
(defun readPiecesFile()
  (setq pieces nil)
  (open-input-file pieces.txt)
  (loop
    (setq tmp (read pieces.txt T 'EOF))
    ((equal tmp 'EOF))
    (push tmp pieces)
  )
  (close-input-file pieces.txt)
)
(defun readLevelFile()
  (open-input-file levelP0.txt)
  (setq level (read levelP0.txt T))
  (close-input-file levelP0.txt)
)
; Funcion para escribir el archivo de salida con la solucion
(defun writeSolution()
  (open-output-file moves.txt 'overwrite)
  (loop
    ((null solution))
    (print (pop solution) moves.txt)
  )
  (close-output-file moves.txt)
)
(defun setLocations()
  (setq locations nil) 
  ; (push (list 1 -5) locations)
  ; (push (list 4 -5) locations)
  ; (push (list 2 -5) locations)
  ; (push (list 3 -5) locations)  
  (push (list 3 -6) locations)
  (push (list 4 -6) locations)
  (push (list 2 -6) locations)
  (push (list 3 -7) locations)
  (push (list 4 -7) locations)
  (push (list 4 -8) locations)  
)
; Funcion que contiene una lista con las casillas del tablero (q,r)
(defun setEmptyBoard ()
  (setq emptyBoard nil)
  (setq q -4)
  (loop
    ((equal q 5))
    (setq r -4)
    (loop
      ((equal r 5))
      (push (list q r) emptyBoard)
      (incq r)
    )
    (incq q)
  )
  (setq q -8)
  (loop
    ((equal q -4))
    (setq r (- -4 q))
    (loop
      ((equal r 5))
      (push (list q r) emptyBoard)
      (incq r)
    )
    (incq q)
  )
  (setq q -4)
  (loop
    ((equal q 0))
    (setq r 5)
    (loop
      ((equal r (- 5 q)))
      (push (list q r) emptyBoard)
      (incq r)
    )
    (incq q)
  ) 
  (setq q 1)
  (loop
    ((equal q 5))
    (setq r (- -4 q))
    (loop
      ((equal r -4))
      (push (list q r) emptyBoard)
      (incq r)
    )
    (incq q)
  ) 
  (setq q 5)
  (loop
    ((equal q 9))
    (setq r -4)
    (loop
      ((equal r (- 5 q)))
      (push (list q r) emptyBoard)
      (incq r)
    )
    (incq q)
  )   
)
(defun getFreeLoaction (lst)
  (setq lstTmp locations)
  (loop
    ((null lstTmp) ())
    (setq loc (pop lstTmp))
    ((freeLocation (nth 0 loc) (nth 1 loc) lst) loc)
  )
)
; Elimina pieza dado un movimiento siempre y cuando corresponda el color. La usa movePiece
(defun deletePiece (move lst)
  ((null lst) nil)
  ((and (equal (nth 0 move) (nth 0 (car lst))) (equal (nth 1 move) (nth 1 (car lst))) (equal (nth 4 move) (nth 2 (car lst)))) (cdr lst))
  (cons (car lst) (deletePiece move (cdr lst)))
)
; Funcion que dada una lista de piezas y una lista de movimientos te regresa la lista de piezas resultante
(defun movePiece (moves lst)
  (setq lstTmp lst)
  (setq lstTmp (deletePiece (car moves) lstTmp))
  (setq moveTmp (nth (- (length moves) 1) moves))
  (push (list (nth 2 moveTmp) (nth 3 moveTmp) (nth 4 moveTmp)) lstTmp)
  lstTmp
)
; Funcion Heuristica
(defun heu1 ()
  (setq res 0 res1 0)
  (setq piecesCopy (nth 2 currentNode))
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    (( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8))) ))
  )
  ;((= color pieceColor) res)
  ;res1
  res 
)
(defun heu1 ()
  (setq res 0 res1 0)
  (setq piecesCopy (nth 2 currentNode))
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    (setq tmplo (getFreeLoaction (nth 2 tmpPiece)))
    ;(( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) (nth 0 tmplo) (nth 1 tmplo)))) ))
    (( (equal color (nth 2 tmpPiece))
      (setq res (+ res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8)))
      ;(setq res (+ res (* 0.1 (- (length (nth 3 currentNode)) 1))))
      ((not (freeLocation (nth 0 tmpPiece) (nth 1 tmpPiece) locations))) (setq res (- res 1))
    ))
  )
  (setq piecesCopy pieces)
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    ;(setq tmplo (getFreeLoaction (nth 2 tmpPiece)))
    ;(( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) (nth 0 tmplo) (nth 1 tmplo)))) ))
    (( (equal color (nth 2 tmpPiece))
      (setq res1 (+ res1 (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8)))
      ;(setq res (+ res (* 0.1 (- (length (nth 3 currentNode)) 1))))
      ;((not (freeLocation (nth 0 tmpPiece) (nth 1 tmpPiece) locations))) (setq res (- res 1))
    ))
  )
  (- res1 res)
  ;res
)

(defun heu1 ()
  (setq res 0 res1 0)
  (setq piecesCopy (nth 2 currentNode))
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    ((
      (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8))) 
      (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 3 -7)))
      (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -7)))
      (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 2 -6)))
      (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 3 -6)))
      (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -6)))
      (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 1 -5)))
      (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 2 -5)))
      (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 3 -5)))
      (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -5)))      
    ))

  )
  ;((= color pieceColor) res)
  ;res1
  res 
)
(defun heu1 ()
  (setq res 0 res1 0)
  (setq piecesCopy (nth 2 currentNode))
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    (setq tmplo (getFreeLoaction (nth 2 tmpPiece)))
    ;(( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) (nth 0 tmplo) (nth 1 tmplo)))) ))
    (( (equal color (nth 2 tmpPiece))
      (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8)))
      (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 2 -6)))
      (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -6)))
      ;(setq res (+ res (* 0.1 (- (length (nth 3 currentNode)) 1))))
      ;((not (freeLocation (nth 0 tmpPiece) (nth 1 tmpPiece) locations))) (setq res (- res 1))
    ))
  )res
)
(defun heu1 ()
  (setq res 0 res1 0)
  (setq piecesCopy (nth 2 currentNode))
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    ;(setq tmplo (getFreeLoaction (nth 2 tmpPiece)))
    ;(( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) (nth 0 tmplo) (nth 1 tmplo)))) ))
    (( (equal color (nth 2 tmpPiece))
      (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8)))
      ((freeLocation (+ (nth 0 tmpPiece) 1) (- (nth 1 tmpPiece) 1) (nth 2 currentNode)) (setq res (- res 0)) )
      ((freeLocation (+ (nth 0 tmpPiece) 1) (nth 1 tmpPiece) (nth 2 currentNode)) (setq res (- res 0)) )
      ((freeLocation (nth 0 tmpPiece) (+ (nth 1 tmpPiece) 1) (nth 2 currentNode)) (setq res (- res 0)) )
      ((freeLocation (- (nth 0 tmpPiece) 1) (+ (nth 1 tmpPiece) 1) (nth 2 currentNode)) (setq res (- res 0)) )
      ((freeLocation (- (nth 0 tmpPiece) 1) (nth 1 tmpPiece) (nth 2 currentNode)) (setq res (- res 0)) )
      ((freeLocation (nth 0 tmpPiece) (- (nth 1 tmpPiece) 1) (nth 2 currentNode)) (setq res (- res 0)) )
      ;(setq res (+ res (* 0.1 (- (length (nth 3 currentNode)) 1))))
      ;((not (freeLocation (nth 0 tmpPiece) (nth 1 tmpPiece) locations))) (setq res (- res 1))
    ))
  )
  (setq piecesCopy pieces)
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    (( (equal color (nth 2 tmpPiece))
      (setq res1 (+ res1 (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8)))
    ))
  )
  ;res
  (+ res res1)
)
(defun heu1 ()
  (setq res 0 res1 0)
  (setq piecesCopy (nth 2 currentNode))
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    (( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8))) ))
    (( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 3 -7))) ))
    (( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -7))) ))
    (( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 3 -6))) ))
    (( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 2 -5))) ))
    (( (equal color (nth 2 tmpPiece)) (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 3 -5))) ))
  )
  ;((= color pieceColor) res)
  ;res1
  res 
)
(defun heu1 ()
  (setq res 0 res1 0)
  (setq piecesCopy (nth 2 currentNode))
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    (setq tmplo (getFreeLoaction (nth 2 tmpPiece)))
    (( (equal color (nth 2 tmpPiece))
      (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) (nth 0 tmplo) (nth 1 tmplo))))
      (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8 )))
      ; (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -7 )))
      ; (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 3 -7 )))
      ; (setq res (+ res (* 0.1 (- (length (nth 3 currentNode)) 1))))
      ; ((not (freeLocation (nth 0 tmpPiece) (nth 1 tmpPiece) locations))) (setq res (- res 1))
    ))
  )
  res
)
(defun heu1 ()
  (setq res 0 res1 0)
  (setq piecesCopy (nth 2 currentNode))
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
(( (equal color (nth 2 tmpPiece))
      (setq res (- res (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8)))
      ((freeLocation (+ (nth 0 tmpPiece) 1) (- (nth 1 tmpPiece) 1) (nth 2 currentNode)) (setq res (- res 2)) )
      ((freeLocation (+ (nth 0 tmpPiece) 1) (nth 1 tmpPiece) (nth 2 currentNode)) (setq res (- res 0.5)) )
      ((freeLocation (nth 0 tmpPiece) (+ (nth 1 tmpPiece) 1) (nth 2 currentNode)) (setq res (- res 0)) )
      ((freeLocation (- (nth 0 tmpPiece) 1) (+ (nth 1 tmpPiece) 1) (nth 2 currentNode)) (setq res (- res 0)) )
      ((freeLocation (- (nth 0 tmpPiece) 1) (nth 1 tmpPiece) (nth 2 currentNode)) (setq res (- res 0.5)) )
      ((freeLocation (nth 0 tmpPiece) (- (nth 1 tmpPiece) 1) (nth 2 currentNode)) (setq res (- res 2)) )
    ))
  )
  (setq piecesCopy pieces)
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    (( (equal color (nth 2 tmpPiece))
      (setq res1 (+ res1 (distance (nth 0 tmpPiece) (nth 1 tmpPiece) 4 -8)))
    ))
  )
  (+ res res1)
)
; Distancia entre dos posiciones
(defun distance(qOr rOr qDes rDes)
  (/ (+ (abs (- qOr qDes)) (abs (- (+ qOr rOr) qDes rDes) ) (abs (- rOr rDes))) 2)
)
; Funcion que valida si la posicion q,r es parte del tablero
(defun partOfBoard(q r lst)
  ((null lst) nil)
  ((and (equal q (nth 0 (car lst))) (equal r (nth 1 (car lst))) ) T)
  (partOfBoard q r (cdr lst))
)
; Funcion para buscar si una posicion q,r esta libre en la lista de piezas
(defun freeLocation (q r lst)
  ((null lst) T)
  ((and (equal q (nth 0 (car lst))) (equal r (nth 1 (car lst))) ) nil)
  (freeLocation q r (cdr lst))
)
; Funcion que genera los sucesores posibles del currentNode
(defun generateSucessors ()
  (setq sucessors nil)
  (setq piecesCopy (nth 2 currentNode))
  (loop
    ((null piecesCopy))
    (setq tmpPiece (pop piecesCopy))
    (setq pieceColor (mod (nth 4 currentNode) 2))
    (jumps tmpPiece (nth 2 currentNode) (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (nth 0 tmpPiece) (nth 1 tmpPiece) pieceColor)) (nth 2 currentNode))
    (( (and (equal pieceColor (nth 2 tmpPiece)) (freeLocation (+ (nth 0 tmpPiece) 1) (- (nth 1 tmpPiece) 1) (nth 2 currentNode)) (partOfBoard (+ (nth 0 tmpPiece) 1) (- (nth 1 tmpPiece) 1) emptyBoard))(
      (push (list (movePiece (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (+ (nth 0 tmpPiece) 1) (- (nth 1 tmpPiece) 1) pieceColor)) (nth 2 currentNode)) (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (+ (nth 0 tmpPiece) 1) (- (nth 1 tmpPiece) 1) pieceColor))) sucessors )
    )))
    (( (and (equal pieceColor (nth 2 tmpPiece)) (freeLocation (+ (nth 0 tmpPiece) 1) (nth 1 tmpPiece) (nth 2 currentNode)) (partOfBoard (+ (nth 0 tmpPiece) 1) (nth 1 tmpPiece) emptyBoard))(
      (push (list (movePiece (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (+ (nth 0 tmpPiece) 1) (nth 1 tmpPiece) pieceColor)) (nth 2 currentNode)) (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (+ (nth 0 tmpPiece) 1) (nth 1 tmpPiece) pieceColor))) sucessors )
    )))
    (( (and (equal pieceColor (nth 2 tmpPiece)) (freeLocation (nth 0 tmpPiece) (+ (nth 1 tmpPiece) 1) (nth 2 currentNode)) (partOfBoard (nth 0 tmpPiece) (+ (nth 1 tmpPiece) 1) emptyBoard))(
      (push (list (movePiece (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (nth 0 tmpPiece) (+ (nth 1 tmpPiece) 1) pieceColor)) (nth 2 currentNode)) (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (nth 0 tmpPiece) (+ (nth 1 tmpPiece) 1) pieceColor))) sucessors )
    )))
    (( (and (equal pieceColor (nth 2 tmpPiece)) (freeLocation (- (nth 0 tmpPiece) 1) (+ (nth 1 tmpPiece) 1) (nth 2 currentNode)) (partOfBoard (- (nth 0 tmpPiece) 1) (+ (nth 1 tmpPiece) 1) emptyBoard))(
      (push (list (movePiece (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (- (nth 0 tmpPiece) 1) (+ (nth 1 tmpPiece) 1) pieceColor)) (nth 2 currentNode)) (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (- (nth 0 tmpPiece) 1) (+ (nth 1 tmpPiece) 1) pieceColor))) sucessors )
    )))
    (( (and (equal pieceColor (nth 2 tmpPiece)) (freeLocation (- (nth 0 tmpPiece) 1) (nth 1 tmpPiece) (nth 2 currentNode)) (partOfBoard (- (nth 0 tmpPiece) 1) (nth 1 tmpPiece) emptyBoard))(
      (push (list (movePiece (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (- (nth 0 tmpPiece) 1) (+ (nth 1 tmpPiece) 1) pieceColor)) (nth 2 currentNode)) (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (- (nth 0 tmpPiece) 1) (nth 1 tmpPiece) pieceColor))) sucessors )
    )))
    (( (and (equal pieceColor (nth 2 tmpPiece)) (freeLocation (nth 0 tmpPiece) (- (nth 1 tmpPiece) 1) (nth 2 currentNode)) (partOfBoard (nth 0 tmpPiece) (- (nth 1 tmpPiece) 1) emptyBoard))(
      (push (list (movePiece (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (nth 0 tmpPiece) (- (nth 1 tmpPiece) 1) pieceColor)) (nth 2 currentNode)) (list (list (nth 0 tmpPiece) (nth 1 tmpPiece) (nth 0 tmpPiece) (- (nth 1 tmpPiece) 1) pieceColor))) sucessors )
    )))
  )
)
; Genera el siguiente salto doble posble de la pieza indicada
(defun jumps (piece piecesLst moves lst)
  (( (and (not  (freeLocation (+ (nth 0 piece) 1) (- (nth 1 piece) 1) piecesLst))
                (freeLocation (+ (nth 0 piece) 2) (- (nth 1 piece) 2) piecesLst)
                (partOfBoard (+ (nth 0 piece) 2) (- (nth 1 piece) 2) emptyBoard)
                (notVisitedPreviously (+ (nth 0 piece) 2) (- (nth 1 piece) 2) moves) )(
    (push  (list (movePiece (list (list (nth 0 piece) (nth 1 piece) (+ (nth 0 piece) 2) (- (nth 1 piece) 2) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (+ (nth 0 piece) 2) (- (nth 1 piece) 2) pieceColor) (list (+ (nth 0 piece) 2) (- (nth 1 piece) 2) (+ (nth 0 piece) 2) (- (nth 1 piece) 2) pieceColor)) moves)) sucessors )
    (jumps (list  (+ (nth 0 piece) 2) (- (nth 1 piece) 2)) (movePiece (list (list (nth 0 piece) (nth 1 piece) (+ (nth 0 piece) 2) (- (nth 1 piece) 2) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (+ (nth 0 piece) 2) (- (nth 1 piece) 2) pieceColor) ) moves) lst )
  )))
  (( (and (not (freeLocation (+ (nth 0 piece) 1) (nth 1 piece) piecesLst)) (freeLocation (+ (nth 0 piece) 2) (nth 1 piece) piecesLst) (partOfBoard (+ (nth 0 piece) 2) (nth 1 piece) emptyBoard) (notVisitedPreviously (+ (nth 0 piece) 2) (nth 1 piece) moves) )(
    (push (list (movePiece (list (list (nth 0 piece) (nth 1 piece) (+ (nth 0 piece) 2) (nth 1 piece) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (+ (nth 0 piece) 2) (nth 1 piece) pieceColor) (list (+ (nth 0 piece) 2) (nth 1 piece) (+ (nth 0 piece) 2) (nth 1 piece) pieceColor)) moves)) sucessors )
    (jumps (list  (+ (nth 0 piece) 2) (nth 1 piece)) (movePiece (list (list (nth 0 piece) (nth 1 piece) (+ (nth 0 piece) 2) (nth 1 piece) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (+ (nth 0 piece) 2) (nth 1 piece) pieceColor) ) moves) lst )
  )))
  (( (and (not (freeLocation (nth 0 piece) (+ (nth 1 piece) 1) piecesLst)) (freeLocation (nth 0 piece) (+ (nth 1 piece) 2) piecesLst) (partOfBoard (nth 0 piece) (+ (nth 1 piece) 2) emptyBoard) (notVisitedPreviously (nth 0 piece) (+ (nth 1 piece) 2) moves) )(
    (push (list (movePiece (list (list (nth 0 piece) (nth 1 piece) (nth 0 piece) (+ (nth 1 piece) 2) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (nth 0 piece) (+ (nth 1 piece) 2) pieceColor) (list (nth 0 piece) (+ (nth 1 piece) 2) (nth 0 piece) (+ (nth 1 piece) 2) pieceColor)) moves)) sucessors )
    (jumps (list  (nth 0 piece) (+ (nth 1 piece) 2)) (movePiece (list (list (nth 0 piece) (nth 1 piece) (nth 0 piece) (+ (nth 1 piece) 2) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (nth 0 piece) (+ (nth 1 piece) 2) pieceColor) ) moves) lst )
  )))
  (( (and (not (freeLocation (- (nth 0 piece) 1) (+ (nth 1 piece) 1) piecesLst)) (freeLocation (- (nth 0 piece) 2) (+ (nth 1 piece) 2) piecesLst) (partOfBoard (- (nth 0 piece) 2) (+ (nth 1 piece) 2) emptyBoard) (notVisitedPreviously (- (nth 0 piece) 2) (+ (nth 1 piece) 2) moves) )(
    (push (list (movePiece (list (list (nth 0 piece) (nth 1 piece) (- (nth 0 piece) 2) (+ (nth 1 piece) 2) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (- (nth 0 piece) 2) (+ (nth 1 piece) 2) pieceColor) (list (- (nth 0 piece) 2) (+ (nth 1 piece) 2) (- (nth 0 piece) 2) (+ (nth 1 piece) 2) pieceColor)) moves)) sucessors )
    (jumps (list  (- (nth 0 piece) 2) (+ (nth 1 piece) 2)) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (- (nth 0 piece) 2) (+ (nth 1 piece) 2) pieceColor) ) moves) lst )
  )))
  (( (and (not (freeLocation (- (nth 0 piece) 1) (nth 1 piece) piecesLst)) (freeLocation (- (nth 0 piece) 2) (nth 1 piece) piecesLst) (partOfBoard (- (nth 0 piece) 2) (nth 1 piece) emptyBoard) (notVisitedPreviously (- (nth 0 piece) 2) (nth 1 piece) moves) )(
    (push (list (movePiece (list (list (nth 0 piece) (nth 1 piece) (- (nth 0 piece) 2) (nth 1 piece) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (- (nth 0 piece) 2) (nth 1 piece) pieceColor) (list (- (nth 0 piece) 2) (nth 1 piece) (- (nth 0 piece) 2) (nth 1 piece) pieceColor)) moves)) sucessors )
    (jumps (list  (- (nth 0 piece) 2) (nth 1 piece)) (movePiece (list (list (nth 0 piece) (nth 1 piece) (- (nth 0 piece) 2) (+ (nth 1 piece) 2) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (- (nth 0 piece) 2) (nth 1 piece) pieceColor) ) moves) lst )
  )))
  (( (and (not (freeLocation (nth 0 piece) (- (nth 1 piece) 1) piecesLst)) (freeLocation (nth 0 piece) (- (nth 1 piece) 2) piecesLst) (partOfBoard (nth 0 piece) (- (nth 1 piece) 2) emptyBoard) (notVisitedPreviously (nth 0 piece) (- (nth 1 piece) 2) moves) )(
    (push (list (movePiece (list (list (nth 0 piece) (nth 1 piece) (nth 0 piece) (- (nth 1 piece) 2) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (nth 0 piece) (- (nth 1 piece) 2) pieceColor) (list (nth 0 piece) (- (nth 1 piece) 2) (nth 0 piece) (- (nth 1 piece) 2) pieceColor)) moves)) sucessors )
    (jumps (list  (nth 0 piece) (- (nth 1 piece) 2)) (movePiece (list (list (nth 0 piece) (nth 1 piece) (nth 0 piece) (- (nth 1 piece) 2) pieceColor) ) piecesLst) (addToEndOfListForJump (list (list (nth 0 piece) (nth 1 piece) (nth 0 piece) (- (nth 1 piece) 2) pieceColor) ) moves) lst )
  )))
)
; Funcion que procesa los nodos sucesores del currentNode
(defun addSucesssorsToOpenList ()
  (loop
    ((null sucessors))
    (setq currentSuc (pop sucessors))
    (setq openlist (cons (list  (incq noNode)
                                (nth 0 currentNode) 
                                (nth 0 currentSuc) 
                                (nth 1 currentSuc) 
                                (add1 (nth 4 currentNode)) 
                                (cond ((= (mod (nth 4 currentNode) 2) 0) alfa) (beta) ) ) 
                    openList))
  )
)
(defun addToEndOfList (val lst)
  ((null lst) (list val))
  (cons (car lst) (addToEndOfList val (cdr lst)))
)
; Funcion
(defun addToEndOfListForJump (vals lst)
  (setq lst2 lst)
  ((null lst2) vals)
  (loop
    ((null vals) lst2)
    (setq lst2 (cons (car lst2) (addToEndOfList (pop vals) (cdr lst2))))
  )
)
; Funcion
(defun notVisitedPreviously (q r lst)
  ((null lst) T)
  ((equal (list q r) (car lst)) nil)
  (notVisitedPreviously q r (cdr lst))
)
; Funcion que ve si se visito un lugar dada una lista de movimientos y una lista de piezas inicial
(defun notVisitedPreviously (q r moves)
  ((null moves) T)
  ((and (equal q (nth 2 (car moves))) (equal r (nth 3 (car moves))))  nil)
  (notVisitedPreviously q r (cdr moves))
)
; Funcion que regresa el padre de un nodo
(defun parentOf (node lst)
  ((null lst) nil)
  ((equal (nth 1 node) (nth 0 (car lst))) (car lst))
  (parentOf node (cdr lst))
)
; Funcion que regresa T si hay al menos hermano del nodo en la lista
(defun brothersOn (node lst)
  ((null lst) nil)
  ((equal (nth 1 node) (nth 1 (car lst))) T)
  nil
)
; Funcion que elimina un nodo de closeList 
(defun deleteNodeFromCloseList (node)
  (setq closeList (deleteNode node closeList))
)
; Regresa la lista sin el nodo, usada por: deleteNodeFromCloseList
(defun deleteNode (node lst)
  ((null lst) nil)
  ((equal (nth 0 node) (nth 0 (car lst))) (cdr lst))
  (cons (car lst) (deleteNode node (cdr lst)))
)
(defun updateF (node newF lst)
  ;((equal (nth 0 node) (nth 0 (car lst))) (addToEndOfList (list (nth 0 node) (nth 1 node) (nth 2 node) (nth 3 node) (nth 4 node) newF ) (cdr lst)) )
  ((equal (nth 0 node) (nth 0 (car lst))) (cons (list (nth 0 node) (nth 1 node) (nth 2 node) (nth 3 node) (nth 4 node) newF ) (cdr lst)) )
  (cons (car lst) (updateF node newF (cdr lst)))
)
(defun updateFOnclose (node newF)
  (setq closeList (updateF node newF closeList))
)
; Funcion que regresa T si contiene un padre con valor reemplazable, mismo que reemplaza
(defun replaceableParent (node)
  ((null (nth 1 node)))
  (setq pieceColor (mod (nth 4 node) 2))
  (setq parent (parentOf node closeList))
  ((or (and (not (equal pieceColor color)) (< (nth 5 node) (nth 5 parent) ))
        (and (equal pieceColor color) (> (nth 5 node) (nth 5 parent) ))) 
        (updateFOnclose parent (nth 5 node))
        ;(pruning node) 
  )
)
; Funcion que borra los hermanos de un nodo una lista
(defun deleteBrothers (node lst)
  ((null lst) nil)
  ((equal (nth 1 node) (nth 1 (car lst))) (deleteBrothers node (cdr lst)) )
  (cons (car lst) (deleteBrothers node (cdr lst)))
)
(defun deleteBrothersOpenlist (node)
  (loop
    ((null openList))
    ((not (equal (nth 1 node) (nth 1 (car lst)))))
    (((equal (nth 1 node) (nth 1 (car lst))) (pop openList) ))
  )
)
; Funcion que poda, revisa si tiene abuelo y si cumple para podar
(defun pruning (node)
  (setq parent (parentOf node closeList))
  ((null (nth 1 parent)))
  (setq pieceColor (mod (nth 4 node) 2))
  (setq grandPa (parentOf parent closeList))
  ((or (and (not (equal pieceColor color)) (< (nth 5 node) (nth 5 grandPa) )) (and (equal pieceColor color) (> (nth 5 node) (nth 5 grandPa) )) ) (deleteBrothersOpenlist node) )
)
; Funcion que sube el valor f de un nodo al padre
(defun climb (node)
  ((null node))
  (( (> (nth 4 node) 1) (deleteNodeFromCloseList node) ))
  (replaceableParent node)
  ((null (brothersOn node openList)) (climb (parentOf node closeList)))
)
; Busca el nodo con mejor f
(defun betterNode ()
  (setq bestNode (list 0 nil nil nil 0 alfa))
  (deleteNodeFromCloseList bestNode)
  (loop
    ((null closeList))
    (setq currentNode (pop closeList))
    (setq pieceColor (mod (nth 4 currentNode) 2))
    (((> (nth 5 currentNode) (nth 5 bestNode)) (setq bestNode currentNode) ))
  )
)
; Funcion para inicializar variables
(defun init()
  (setq level 2 noNode 0)
  (readLevelFile)
  (setLocations)
  (setq alfa -999 beta 999)
  (setq openList nil closeList nil solution nil color 0)
  (setEmptyBoard)
  (readPiecesFile)
  (push (list noNode nil pieces nil 0 alfa) openList)
)
; Definicion de nodo;
; ( 0       1              2      3      4     5 )
; ( no_node no_parent_node pieces (movs) level f )
; Funcion principal damas
; color = 0-blanco, 1-negro
(defun damas()
  (init)
  (loop
    ((null openList))
    (setq currentNode (pop openList))
    (cond 
      ((not (equal (nth 4 currentNode) level))
        (generateSucessors)
        (addSucesssorsToOpenList)
        (push currentNode closeList)
      )
      ((equal (nth 4 currentNode) level)
        (setq currentNode (list (nth 0 currentNode) (nth 1 currentNode) (nth 2 currentNode) (nth 3 currentNode) (nth 4 currentNode) (heu1) ) )
        (push currentNode closeList)
        (climb currentNode)
      )
    )
  )
  (betterNode)
  (setq solution (nth 3 bestNode))
  (writeSolution)
)
(damas)
(system)