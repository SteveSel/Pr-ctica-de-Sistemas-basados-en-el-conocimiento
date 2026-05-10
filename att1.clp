;; ======================================================================
;; PROTOTIPO INICIAL: AGENCIA DE VIAJES
;; ======================================================================

;; ----------------------------------------------------------------------
;; 1. ONTOLOGÍA (Estructuras de datos)
;; ----------------------------------------------------------------------
(deftemplate Usuario
    (slot motivo_viaje (type SYMBOL) (allowed-symbols Romantico Cultural Relax Desconocido) (default Desconocido))
    (slot presupuesto_maximo (type FLOAT) (default 0.0))
)

(deftemplate Ciudad
    (slot nombre (type STRING))
    (slot tematica (type SYMBOL))
)

(deftemplate Alojamiento
    (slot nombre (type STRING))
    (slot ciudad_ubicacion (type STRING))
    (slot precio_total (type FLOAT))
)

(deftemplate Viaje_Generado
    (slot ciudad_destino (type STRING))
    (slot alojamiento_destino (type STRING))
    (slot precio_final (type FLOAT))
)

;; ----------------------------------------------------------------------
;; 2. BASE DE CONOCIMIENTO (Catálogo inicial reducido)
;; ----------------------------------------------------------------------
(deffacts Catalogo_Y_Estado_Inicial
    ;; Establecemos la fase inicial del programa
    (fase inicio)

    ;; Ciudades
    (Ciudad (nombre "Paris") (tematica Romantico))
    (Ciudad (nombre "Roma") (tematica Cultural))
    (Ciudad (nombre "Bali") (tematica Relax))

    ;; Alojamientos (Precio total por todo el viaje para simplificar el prototipo)
    (Alojamiento (nombre "Hotel Ritz 5*") (ciudad_ubicacion "Paris") (precio_total 3000.0))
    (Alojamiento (nombre "Hostal Amour") (ciudad_ubicacion "Paris") (precio_total 500.0))
    
    (Alojamiento (nombre "Hotel Coliseo 4*") (ciudad_ubicacion "Roma") (precio_total 1200.0))
    (Alojamiento (nombre "Apartamento Roma") (ciudad_ubicacion "Roma") (precio_total 400.0))
    
    (Alojamiento (nombre "Villa Selva 5*") (ciudad_ubicacion "Bali") (precio_total 2000.0))
)

;; ----------------------------------------------------------------------
;; 3. MÓDULO DE INTERFAZ (Preguntas al usuario)
;; ----------------------------------------------------------------------
(defrule Iniciar_Sistema
    ?f <- (fase inicio)
    =>
    (retract ?f)
    (printout t "==================================================" crlf)
    (printout t " BIENVENIDO A LA AGENCIA DE VIAJES EXPERTA" crlf)
    (printout t "==================================================" crlf)
    (assert (fase preguntar_motivo))
)

(defrule Preguntar_Motivo
    ?f <- (fase preguntar_motivo)
    =>
    (retract ?f)
    (printout t "¿Cual es el motivo principal de tu viaje? (Romantico / Cultural / Relax): ")
    (bind ?respuesta (read))
    ;; Guardamos un usuario temporal solo con el motivo
    (assert (Usuario (motivo_viaje ?respuesta)))
    (assert (fase preguntar_presupuesto))
)

(defrule Preguntar_Presupuesto
    ?f <- (fase preguntar_presupuesto)
    ?usr <- (Usuario (presupuesto_maximo 0.0)) ;; Buscamos el usuario recién creado
    =>
    (retract ?f)
    (printout t "¿Cual es tu presupuesto maximo total en euros? (ej. 1500.0): ")
    (bind ?presup (read))
    ;; Actualizamos el usuario con el presupuesto insertado
    (modify ?usr (presupuesto_maximo ?presup))
    (printout t "--------------------------------------------------" crlf)
    (printout t "Analizando opciones..." crlf)
    (assert (fase razonamiento))
)

;; ----------------------------------------------------------------------
;; 4. MÓDULO DE RAZONAMIENTO E INFERENCIA
;; ----------------------------------------------------------------------
(defrule Buscar_Viaje_Ideal
    ?f <- (fase razonamiento)
    (Usuario (motivo_viaje ?motivo) (presupuesto_maximo ?presup_max))
    
    ;; Buscamos una ciudad que coincida con el motivo del viaje
    (Ciudad (nombre ?nom_ciudad) (tematica ?motivo))
    
    ;; Buscamos un alojamiento en esa ciudad que no supere el presupuesto
    (Alojamiento (nombre ?nom_aloj) (ciudad_ubicacion ?nom_ciudad) (precio_total ?precio_aloj&:(<= ?precio_aloj ?presup_max)))
    =>
    (retract ?f)
    ;; Si encontramos uno, generamos el hecho del viaje final
    (assert (Viaje_Generado (ciudad_destino ?nom_ciudad) (alojamiento_destino ?nom_aloj) (precio_final ?precio_aloj)))
    (assert (fase presentacion_resultados))
)

;; Regla de seguridad (Por si el presupuesto es muy bajo y no hay opciones)
(defrule Sin_Opciones
    ?f <- (fase razonamiento)
    ;; Si no se ha generado ningún Viaje_Generado en la regla anterior...
    (not (Viaje_Generado))
    =>
    (retract ?f)
    (printout t "Lo sentimos, no hemos encontrado ningun viaje que se ajuste a ese presupuesto y motivo." crlf)
    (assert (fase fin))
)

;; ----------------------------------------------------------------------
;; 5. MÓDULO DE PRESENTACIÓN DE RESULTADOS
;; ----------------------------------------------------------------------
(defrule Mostrar_Recomendacion
    ?f <- (fase presentacion_resultados)
    ?viaje <- (Viaje_Generado (ciudad_destino ?c) (alojamiento_destino ?a) (precio_final ?p))
    =>
    ;; Retiramos el viaje para que la regla no se ejecute en bucle infinito si hay varios
    (retract ?viaje) 
    (printout t ">>> VIAJE RECOMENDADO ENCONTRADO <<<" crlf)
    (printout t "Destino: " ?c crlf)
    (printout t "Alojamiento: " ?a crlf)
    (printout t "Precio Total: " ?p " euros" crlf)
    (printout t "==================================================" crlf)
    (assert (fase fin))
)