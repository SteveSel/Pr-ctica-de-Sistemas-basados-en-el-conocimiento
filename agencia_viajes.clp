;; ONTOLOGÍA

;; Datos recogidos directamente del usuario mediante las preguntas del sistema.
;; Todos los slots tienen default para evitar errores si alguna respuesta falla.
(deftemplate Usuario
    (slot motivo          (type SYMBOL)
          (allowed-symbols Romantico Cultural Relax Diversion Desconocido)
          (default Desconocido))
    (slot composicion     (type SYMBOL)
          (allowed-symbols Solo Pareja Familia Grupo Desconocido)
          (default Desconocido))
    (slot con_ninos       (type SYMBOL)
          (allowed-symbols si no) (default no))
    (slot dias_totales    (type INTEGER) (default 7))
    (slot presupuesto_max (type FLOAT)   (default 1000.0))
    (slot transporte_pref (type SYMBOL)
          (allowed-symbols Avion Tren Indiferente) (default Indiferente))
    (slot categoria_aloj  (type SYMBOL)
          (allowed-symbols Economico Estandar Lujo) (default Estandar))
)

;; Perfil inferido por el sistema a partir del Usuario.
;; Es rellanado por reglas del modulo de deduccion
(deftemplate Perfil
    (slot motivo_efectivo   (type SYMBOL)   (default Generico))
    (slot max_ciudades      (type INTEGER)  (default 2))
    (slot dias_por_ciudad   (type INTEGER)  (default 2))
    (slot radio_viaje       (type SYMBOL)
          (allowed-symbols Corto Medio Largo) (default Medio))
    (slot presupuesto_nivel (type SYMBOL)
          (allowed-symbols Bajo Medio Alto)  (default Medio))
)

;; Destino turístico del catálogo.
(deftemplate Ciudad
    (slot nombre     (type STRING))
    (slot region     (type SYMBOL)
          (allowed-symbols Europa America Asia Oceania Africa))
    (slot tematica   (type SYMBOL)
          (allowed-symbols Romantico Cultural Relax Diversion Familiar))
    (slot nivel_vida (type SYMBOL) (allowed-symbols Bajo Medio Alto))
    (slot distancia  (type SYMBOL) (allowed-symbols Corta Media Larga))
    (slot apta_ninos (type SYMBOL) (allowed-symbols si no))
)

;; Atracción turística asociada a una ciudad.
(deftemplate LugarVisita
    (slot nombre  (type STRING))
    (slot ciudad  (type STRING))
    (slot interes (type SYMBOL)
          (allowed-symbols Cultural Romantico Naturaleza Ocio Familiar Relax))
    (slot horas   (type INTEGER) (default 2))
)

;; Alojamiento disponible en una ciudad.
(deftemplate Alojamiento
    (slot nombre       (type STRING))
    (slot ciudad       (type STRING))
    (slot categoria    (type SYMBOL) (allowed-symbols Economico Estandar Lujo))
    (slot precio_noche (type FLOAT))
    (slot apto_ninos   (type SYMBOL) (allowed-symbols si no))
)

;; Coneccion de transporte entre 2 puntos.
(deftemplate Transporte
    (slot origen         (type STRING))
    (slot destino        (type STRING))
    (slot tipo           (type SYMBOL) (allowed-symbols Avion Tren Bus))
    (slot precio_persona (type FLOAT))
    (slot horas_viaje    (type FLOAT))
)

;; Una ciudad visitada dentro de un plan, con sus costes y detalles de estancia.
(deftemplate Etapa
    (slot plan_id            (type INTEGER))
    (slot orden              (type INTEGER))
    (slot ciudad             (type STRING))
    (slot dias               (type INTEGER))
    (slot nombre_alojamiento (type STRING))
    (slot tipo_transporte    (type SYMBOL) (allowed-symbols Avion Tren Bus))
    (slot coste_aloj         (type FLOAT))
    (slot coste_transporte   (type FLOAT))
)

;; Lugar de visita ya asignado a una etapa concreta de un plan.
(deftemplate VisitaAsignada
    (slot plan_id (type INTEGER))
    (slot ciudad  (type STRING))
    (slot lugar   (type STRING))
)

;; Cabecera del plan resultado con coste total, días y estado de construcción.
(deftemplate PlanViaje
    (slot plan_id     (type INTEGER))
    (slot coste_total (type FLOAT)   (default 0.0))
    (slot num_dias    (type INTEGER) (default 0))
    (slot estado      (type SYMBOL)
          (allowed-symbols Construyendo Completo Fallido) (default Construyendo))
)

;; Marcador que registra qué ciudades ya han sido incluidas en un plan.
;; Impide repetir ciudades dentro del mismo plan y entre los dos planes.
(deftemplate CiudadUsada
    (slot plan_id (type INTEGER))
    (slot ciudad  (type STRING))
)

;; Acumulador mutable del estado de construcción de un plan en curso.
(deftemplate EstadoPlan
    (slot plan_id       (type INTEGER))
    (slot dias_usados   (type INTEGER) (default 0))
    (slot coste_acum    (type FLOAT)   (default 0.0))
    (slot orden_actual  (type INTEGER) (default 0))
    (slot ultima_ciudad (type STRING)  (default "Origen"))
)


;; BASE DE CONOCIMIENTO

(deffacts Catalogo

    ;; CIUDADES
    (Ciudad (nombre "Paris")       (region Europa)  (tematica Romantico)  (nivel_vida Alto)  (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Santorini")   (region Europa)  (tematica Romantico)  (nivel_vida Alto)  (distancia Corta) (apta_ninos no))
    (Ciudad (nombre "Lisboa")      (region Europa)  (tematica Romantico)  (nivel_vida Bajo)  (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Florencia")   (region Europa)  (tematica Cultural)   (nivel_vida Medio) (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Roma")        (region Europa)  (tematica Cultural)   (nivel_vida Medio) (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Amsterdam")   (region Europa)  (tematica Cultural)   (nivel_vida Alto)  (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Praga")       (region Europa)  (tematica Cultural)   (nivel_vida Bajo)  (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Viena")       (region Europa)  (tematica Cultural)   (nivel_vida Alto)  (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Estambul")    (region Europa)  (tematica Cultural)   (nivel_vida Bajo)  (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Edimburgo")   (region Europa)  (tematica Cultural)   (nivel_vida Medio) (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Marrakech")   (region Africa)  (tematica Cultural)   (nivel_vida Bajo)  (distancia Media) (apta_ninos si))
    (Ciudad (nombre "Tokio")       (region Asia)    (tematica Cultural)   (nivel_vida Alto)  (distancia Larga) (apta_ninos si))
    (Ciudad (nombre "Dubrovnik")   (region Europa)  (tematica Relax)      (nivel_vida Medio) (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Reykjavik")   (region Europa)  (tematica Relax)      (nivel_vida Alto)  (distancia Media) (apta_ninos si))
    (Ciudad (nombre "Bali")        (region Asia)    (tematica Relax)      (nivel_vida Bajo)  (distancia Larga) (apta_ninos si))
    (Ciudad (nombre "Barcelona")   (region Europa)  (tematica Diversion)  (nivel_vida Medio) (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Berlin")      (region Europa)  (tematica Diversion)  (nivel_vida Medio) (distancia Corta) (apta_ninos si))
    (Ciudad (nombre "Bangkok")     (region Asia)    (tematica Diversion)  (nivel_vida Bajo)  (distancia Larga) (apta_ninos si))
    (Ciudad (nombre "Nueva York")  (region America) (tematica Diversion)  (nivel_vida Alto)  (distancia Larga) (apta_ninos si))

    ;; LUGARES A VISITAR
    (LugarVisita (nombre "Torre Eiffel")           (ciudad "Paris")      (interes Romantico)  (horas 3))
    (LugarVisita (nombre "Museo del Louvre")       (ciudad "Paris")      (interes Cultural)   (horas 4))
    (LugarVisita (nombre "Montmartre")             (ciudad "Paris")      (interes Romantico)  (horas 2))
    (LugarVisita (nombre "Musee dOrsay")           (ciudad "Paris")      (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Oia al atardecer")       (ciudad "Santorini")  (interes Romantico)  (horas 3))
    (LugarVisita (nombre "Playa Roja")             (ciudad "Santorini")  (interes Relax)      (horas 4))
    (LugarVisita (nombre "Alfama")                 (ciudad "Lisboa")     (interes Romantico)  (horas 2))
    (LugarVisita (nombre "Belem y Torre")          (ciudad "Lisboa")     (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Sintra")                 (ciudad "Lisboa")     (interes Naturaleza) (horas 4))
    (LugarVisita (nombre "Galeria Uffizi")         (ciudad "Florencia")  (interes Cultural)   (horas 4))
    (LugarVisita (nombre "Duomo di Firenze")       (ciudad "Florencia")  (interes Cultural)   (horas 2))
    (LugarVisita (nombre "Piazzale Michelangelo")  (ciudad "Florencia")  (interes Romantico)  (horas 2))
    (LugarVisita (nombre "Coliseo Romano")         (ciudad "Roma")       (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Vaticano")               (ciudad "Roma")       (interes Cultural)   (horas 4))
    (LugarVisita (nombre "Fontana di Trevi")       (ciudad "Roma")       (interes Romantico)  (horas 1))
    (LugarVisita (nombre "Foro Romano")            (ciudad "Roma")       (interes Cultural)   (horas 2))
    (LugarVisita (nombre "Museo Van Gogh")         (ciudad "Amsterdam")  (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Rijksmuseum")            (ciudad "Amsterdam")  (interes Cultural)   (horas 4))
    (LugarVisita (nombre "Canales Jordaan")        (ciudad "Amsterdam")  (interes Romantico)  (horas 2))
    (LugarVisita (nombre "Castillo de Praga")      (ciudad "Praga")      (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Puente Carlos")          (ciudad "Praga")      (interes Romantico)  (horas 1))
    (LugarVisita (nombre "Plaza Ciudad Vieja")     (ciudad "Praga")      (interes Cultural)   (horas 2))
    (LugarVisita (nombre "Palacio Schonbrunn")     (ciudad "Viena")      (interes Cultural)   (horas 4))
    (LugarVisita (nombre "Opera de Viena")         (ciudad "Viena")      (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Hagia Sophia")           (ciudad "Estambul")   (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Gran Bazar")             (ciudad "Estambul")   (interes Cultural)   (horas 2))
    (LugarVisita (nombre "Palacio Topkapi")        (ciudad "Estambul")   (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Castillo de Edimburgo")  (ciudad "Edimburgo")  (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Arthur Seat")            (ciudad "Edimburgo")  (interes Naturaleza) (horas 3))
    (LugarVisita (nombre "La Medina")              (ciudad "Marrakech")  (interes Cultural)   (horas 4))
    (LugarVisita (nombre "Jardin Majorelle")       (ciudad "Marrakech")  (interes Naturaleza) (horas 2))
    (LugarVisita (nombre "Senso-ji Asakusa")       (ciudad "Tokio")      (interes Cultural)   (horas 2))
    (LugarVisita (nombre "Shibuya Crossing")       (ciudad "Tokio")      (interes Ocio)       (horas 2))
    (LugarVisita (nombre "Monte Fuji")             (ciudad "Tokio")      (interes Naturaleza) (horas 6))
    (LugarVisita (nombre "Murallas de Dubrovnik")  (ciudad "Dubrovnik")  (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Playa Banje")            (ciudad "Dubrovnik")  (interes Relax)      (horas 4))
    (LugarVisita (nombre "Auroras Boreales")       (ciudad "Reykjavik")  (interes Naturaleza) (horas 4))
    (LugarVisita (nombre "Laguna Azul")            (ciudad "Reykjavik")  (interes Relax)      (horas 3))
    (LugarVisita (nombre "Ubud y Arrozales")       (ciudad "Bali")       (interes Naturaleza) (horas 4))
    (LugarVisita (nombre "Seminyak Beach")         (ciudad "Bali")       (interes Relax)      (horas 5))
    (LugarVisita (nombre "Templo Uluwatu")         (ciudad "Bali")       (interes Cultural)   (horas 2))
    (LugarVisita (nombre "Sagrada Familia")        (ciudad "Barcelona")  (interes Cultural)   (horas 3))
    (LugarVisita (nombre "Park Guell")             (ciudad "Barcelona")  (interes Cultural)   (horas 2))
    (LugarVisita (nombre "La Barceloneta")         (ciudad "Barcelona")  (interes Ocio)       (horas 3))
    (LugarVisita (nombre "Puerta Brandenburgo")    (ciudad "Berlin")     (interes Cultural)   (horas 2))
    (LugarVisita (nombre "Checkpoint Charlie")     (ciudad "Berlin")     (interes Cultural)   (horas 2))
    (LugarVisita (nombre "Zona Kreuzberg")         (ciudad "Berlin")     (interes Ocio)       (horas 3))
    (LugarVisita (nombre "Templo Wat Pho")         (ciudad "Bangkok")    (interes Cultural)   (horas 2))
    (LugarVisita (nombre "Mercado Chatuchak")      (ciudad "Bangkok")    (interes Ocio)       (horas 3))
    (LugarVisita (nombre "Central Park")           (ciudad "Nueva York") (interes Ocio)       (horas 3))
    (LugarVisita (nombre "Metropolitan Museum")    (ciudad "Nueva York") (interes Cultural)   (horas 4))
    (LugarVisita (nombre "Times Square")           (ciudad "Nueva York") (interes Ocio)       (horas 2))

    ;; ALOJAMIENTOS
    (Alojamiento (nombre "Hotel Lumiere 5*")        (ciudad "Paris")      (categoria Lujo)      (precio_noche 350.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Seine 3*")          (ciudad "Paris")      (categoria Estandar)  (precio_noche 150.0) (apto_ninos si))
    (Alojamiento (nombre "Hostal Montparnasse")     (ciudad "Paris")      (categoria Economico) (precio_noche 60.0)  (apto_ninos si))
    (Alojamiento (nombre "Villa Caldera 5*")        (ciudad "Santorini")  (categoria Lujo)      (precio_noche 500.0) (apto_ninos no))
    (Alojamiento (nombre "Hotel Fira 3*")           (ciudad "Santorini")  (categoria Estandar)  (precio_noche 180.0) (apto_ninos no))
    (Alojamiento (nombre "Hotel Bairro Alto 5*")    (ciudad "Lisboa")     (categoria Lujo)      (precio_noche 250.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Tejo 3*")           (ciudad "Lisboa")     (categoria Estandar)  (precio_noche 90.0)  (apto_ninos si))
    (Alojamiento (nombre "Hostal Alfama")           (ciudad "Lisboa")     (categoria Economico) (precio_noche 35.0)  (apto_ninos si))
    (Alojamiento (nombre "Hotel Brunelleschi 5*")   (ciudad "Florencia")  (categoria Lujo)      (precio_noche 310.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Arno 3*")           (ciudad "Florencia")  (categoria Estandar)  (precio_noche 115.0) (apto_ninos si))
    (Alojamiento (nombre "Hostal Santa Croce")      (ciudad "Florencia")  (categoria Economico) (precio_noche 42.0)  (apto_ninos si))
    (Alojamiento (nombre "Hotel Imperiale 5*")      (ciudad "Roma")       (categoria Lujo)      (precio_noche 300.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Tevere 3*")         (ciudad "Roma")       (categoria Estandar)  (precio_noche 120.0) (apto_ninos si))
    (Alojamiento (nombre "Hostal Trastevere")       (ciudad "Roma")       (categoria Economico) (precio_noche 45.0)  (apto_ninos si))
    (Alojamiento (nombre "Hotel Pulitzer 5*")       (ciudad "Amsterdam")  (categoria Lujo)      (precio_noche 380.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Canal 3*")          (ciudad "Amsterdam")  (categoria Estandar)  (precio_noche 140.0) (apto_ninos si))
    (Alojamiento (nombre "Hostal Vondelpark")       (ciudad "Amsterdam")  (categoria Economico) (precio_noche 55.0)  (apto_ninos si))
    (Alojamiento (nombre "Hotel Mandarin 5*")       (ciudad "Praga")      (categoria Lujo)      (precio_noche 200.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Moldava 3*")        (ciudad "Praga")      (categoria Estandar)  (precio_noche 80.0)  (apto_ninos si))
    (Alojamiento (nombre "Hostal Stare Mesto")      (ciudad "Praga")      (categoria Economico) (precio_noche 30.0)  (apto_ninos si))
    (Alojamiento (nombre "Hotel Imperial 5*")       (ciudad "Viena")      (categoria Lujo)      (precio_noche 420.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Sacher 3*")         (ciudad "Viena")      (categoria Estandar)  (precio_noche 160.0) (apto_ninos si))
    (Alojamiento (nombre "Hostal Naschmarkt")       (ciudad "Viena")      (categoria Economico) (precio_noche 50.0)  (apto_ninos si))
    (Alojamiento (nombre "Hotel Ciragan Palace 5*") (ciudad "Estambul")   (categoria Lujo)      (precio_noche 290.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Sultanahmet 3*")    (ciudad "Estambul")   (categoria Estandar)  (precio_noche 85.0)  (apto_ninos si))
    (Alojamiento (nombre "Hostal Beyoglu")          (ciudad "Estambul")   (categoria Economico) (precio_noche 28.0)  (apto_ninos si))
    (Alojamiento (nombre "The Witchery 5*")         (ciudad "Edimburgo")  (categoria Lujo)      (precio_noche 280.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Royal Mile 3*")     (ciudad "Edimburgo")  (categoria Estandar)  (precio_noche 100.0) (apto_ninos si))
    (Alojamiento (nombre "Riad Zitoun 5*")          (ciudad "Marrakech")  (categoria Lujo)      (precio_noche 200.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Medina 3*")         (ciudad "Marrakech")  (categoria Estandar)  (precio_noche 70.0)  (apto_ninos si))
    (Alojamiento (nombre "Hostal Djemaa")           (ciudad "Marrakech")  (categoria Economico) (precio_noche 25.0)  (apto_ninos si))
    (Alojamiento (nombre "Hotel Park Hyatt 5*")     (ciudad "Tokio")      (categoria Lujo)      (precio_noche 450.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Shinjuku 3*")       (ciudad "Tokio")      (categoria Estandar)  (precio_noche 150.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Excelsior 5*")      (ciudad "Dubrovnik")  (categoria Lujo)      (precio_noche 350.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Lapad 3*")          (ciudad "Dubrovnik")  (categoria Estandar)  (precio_noche 120.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Borg 5*")           (ciudad "Reykjavik")  (categoria Lujo)      (precio_noche 400.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Reykjavik 3*")      (ciudad "Reykjavik")  (categoria Estandar)  (precio_noche 150.0) (apto_ninos si))
    (Alojamiento (nombre "Resort Seminyak 5*")      (ciudad "Bali")       (categoria Lujo)      (precio_noche 280.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Ubud 3*")           (ciudad "Bali")       (categoria Estandar)  (precio_noche 90.0)  (apto_ninos si))
    (Alojamiento (nombre "Hostal Kuta")             (ciudad "Bali")       (categoria Economico) (precio_noche 25.0)  (apto_ninos si))
    (Alojamiento (nombre "Hotel Arts 5*")           (ciudad "Barcelona")  (categoria Lujo)      (precio_noche 400.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Gaudi 3*")          (ciudad "Barcelona")  (categoria Estandar)  (precio_noche 130.0) (apto_ninos si))
    (Alojamiento (nombre "Hostal Gracia")           (ciudad "Barcelona")  (categoria Economico) (precio_noche 50.0)  (apto_ninos si))
    (Alojamiento (nombre "Hotel Adlon 5*")          (ciudad "Berlin")     (categoria Lujo)      (precio_noche 320.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Mitte 3*")          (ciudad "Berlin")     (categoria Estandar)  (precio_noche 110.0) (apto_ninos si))
    (Alojamiento (nombre "Hostal Kreuzberg")        (ciudad "Berlin")     (categoria Economico) (precio_noche 40.0)  (apto_ninos si))
    (Alojamiento (nombre "Plaza Hotel 5*")          (ciudad "Nueva York") (categoria Lujo)      (precio_noche 500.0) (apto_ninos si))
    (Alojamiento (nombre "Hotel Times Square 3*")   (ciudad "Nueva York") (categoria Estandar)  (precio_noche 180.0) (apto_ninos si))

    ;; TRANSPORTES
    ;; Desde el origen del viajero
    (Transporte (origen "Origen") (destino "Paris")      (tipo Avion) (precio_persona 120.0) (horas_viaje 2.0))
    (Transporte (origen "Origen") (destino "Santorini")  (tipo Avion) (precio_persona 160.0) (horas_viaje 3.5))
    (Transporte (origen "Origen") (destino "Lisboa")     (tipo Avion) (precio_persona 100.0) (horas_viaje 2.5))
    (Transporte (origen "Origen") (destino "Florencia")  (tipo Avion) (precio_persona 120.0) (horas_viaje 2.0))
    (Transporte (origen "Origen") (destino "Roma")       (tipo Avion) (precio_persona 130.0) (horas_viaje 2.5))
    (Transporte (origen "Origen") (destino "Amsterdam")  (tipo Avion) (precio_persona 140.0) (horas_viaje 2.5))
    (Transporte (origen "Origen") (destino "Praga")      (tipo Avion) (precio_persona 110.0) (horas_viaje 2.5))
    (Transporte (origen "Origen") (destino "Viena")      (tipo Avion) (precio_persona 125.0) (horas_viaje 2.5))
    (Transporte (origen "Origen") (destino "Estambul")   (tipo Avion) (precio_persona 160.0) (horas_viaje 3.5))
    (Transporte (origen "Origen") (destino "Edimburgo")  (tipo Avion) (precio_persona 130.0) (horas_viaje 2.5))
    (Transporte (origen "Origen") (destino "Dubrovnik")  (tipo Avion) (precio_persona 150.0) (horas_viaje 3.0))
    (Transporte (origen "Origen") (destino "Reykjavik")  (tipo Avion) (precio_persona 200.0) (horas_viaje 4.0))
    (Transporte (origen "Origen") (destino "Bali")       (tipo Avion) (precio_persona 650.0) (horas_viaje 14.0))
    (Transporte (origen "Origen") (destino "Barcelona")  (tipo Tren)  (precio_persona 30.0)  (horas_viaje 2.0))
    (Transporte (origen "Origen") (destino "Barcelona")  (tipo Avion) (precio_persona 60.0)  (horas_viaje 1.0))
    (Transporte (origen "Origen") (destino "Berlin")     (tipo Avion) (precio_persona 115.0) (horas_viaje 2.5))
    (Transporte (origen "Origen") (destino "Marrakech")  (tipo Avion) (precio_persona 140.0) (horas_viaje 2.5))
    (Transporte (origen "Origen") (destino "Tokio")      (tipo Avion) (precio_persona 700.0) (horas_viaje 12.0))
    (Transporte (origen "Origen") (destino "Nueva York") (tipo Avion) (precio_persona 500.0) (horas_viaje 9.0))
    (Transporte (origen "Origen") (destino "Bangkok")    (tipo Avion) (precio_persona 600.0) (horas_viaje 11.0))
    ;; Entre ciudades
    (Transporte (origen "Paris")     (destino "Roma")       (tipo Avion) (precio_persona 90.0)  (horas_viaje 2.0))
    (Transporte (origen "Paris")     (destino "Roma")       (tipo Tren)  (precio_persona 110.0) (horas_viaje 11.0))
    (Transporte (origen "Paris")     (destino "Amsterdam")  (tipo Avion) (precio_persona 80.0)  (horas_viaje 1.5))
    (Transporte (origen "Paris")     (destino "Amsterdam")  (tipo Tren)  (precio_persona 60.0)  (horas_viaje 3.5))
    (Transporte (origen "Paris")     (destino "Barcelona")  (tipo Avion) (precio_persona 80.0)  (horas_viaje 1.5))
    (Transporte (origen "Paris")     (destino "Barcelona")  (tipo Tren)  (precio_persona 70.0)  (horas_viaje 6.5))
    (Transporte (origen "Paris")     (destino "Berlin")     (tipo Avion) (precio_persona 100.0) (horas_viaje 2.0))
    (Transporte (origen "Paris")     (destino "Lisboa")     (tipo Avion) (precio_persona 100.0) (horas_viaje 2.5))
    (Transporte (origen "Paris")     (destino "Viena")      (tipo Avion) (precio_persona 100.0) (horas_viaje 2.0))
    (Transporte (origen "Roma")      (destino "Paris")      (tipo Avion) (precio_persona 90.0)  (horas_viaje 2.0))
    (Transporte (origen "Roma")      (destino "Florencia")  (tipo Tren)  (precio_persona 30.0)  (horas_viaje 1.5))
    (Transporte (origen "Roma")      (destino "Florencia")  (tipo Avion) (precio_persona 60.0)  (horas_viaje 1.0))
    (Transporte (origen "Roma")      (destino "Amsterdam")  (tipo Avion) (precio_persona 95.0)  (horas_viaje 2.5))
    (Transporte (origen "Roma")      (destino "Berlin")     (tipo Avion) (precio_persona 100.0) (horas_viaje 2.0))
    (Transporte (origen "Roma")      (destino "Viena")      (tipo Tren)  (precio_persona 80.0)  (horas_viaje 12.0))
    (Transporte (origen "Florencia") (destino "Roma")       (tipo Tren)  (precio_persona 30.0)  (horas_viaje 1.5))
    (Transporte (origen "Florencia") (destino "Viena")      (tipo Avion) (precio_persona 100.0) (horas_viaje 2.0))
    (Transporte (origen "Amsterdam") (destino "Paris")      (tipo Avion) (precio_persona 80.0)  (horas_viaje 1.5))
    (Transporte (origen "Amsterdam") (destino "Berlin")     (tipo Avion) (precio_persona 80.0)  (horas_viaje 1.5))
    (Transporte (origen "Amsterdam") (destino "Berlin")     (tipo Tren)  (precio_persona 70.0)  (horas_viaje 6.0))
    (Transporte (origen "Amsterdam") (destino "Praga")      (tipo Avion) (precio_persona 90.0)  (horas_viaje 2.0))
    (Transporte (origen "Praga")     (destino "Viena")      (tipo Tren)  (precio_persona 35.0)  (horas_viaje 4.0))
    (Transporte (origen "Praga")     (destino "Berlin")     (tipo Tren)  (precio_persona 40.0)  (horas_viaje 4.0))
    (Transporte (origen "Praga")     (destino "Berlin")     (tipo Avion) (precio_persona 70.0)  (horas_viaje 1.5))
    (Transporte (origen "Viena")     (destino "Praga")      (tipo Tren)  (precio_persona 35.0)  (horas_viaje 4.0))
    (Transporte (origen "Viena")     (destino "Roma")       (tipo Avion) (precio_persona 90.0)  (horas_viaje 2.0))
    (Transporte (origen "Viena")     (destino "Berlin")     (tipo Avion) (precio_persona 80.0)  (horas_viaje 1.5))
    (Transporte (origen "Berlin")    (destino "Amsterdam")  (tipo Avion) (precio_persona 80.0)  (horas_viaje 1.5))
    (Transporte (origen "Berlin")    (destino "Praga")      (tipo Tren)  (precio_persona 40.0)  (horas_viaje 4.0))
    (Transporte (origen "Berlin")    (destino "Viena")      (tipo Avion) (precio_persona 80.0)  (horas_viaje 1.5))
    (Transporte (origen "Barcelona") (destino "Paris")      (tipo Tren)  (precio_persona 70.0)  (horas_viaje 6.5))
    (Transporte (origen "Barcelona") (destino "Roma")       (tipo Avion) (precio_persona 90.0)  (horas_viaje 2.0))
    (Transporte (origen "Barcelona") (destino "Lisboa")     (tipo Avion) (precio_persona 80.0)  (horas_viaje 2.0))
    (Transporte (origen "Lisboa")    (destino "Barcelona")  (tipo Avion) (precio_persona 80.0)  (horas_viaje 2.0))
    (Transporte (origen "Lisboa")    (destino "Marrakech")  (tipo Avion) (precio_persona 120.0) (horas_viaje 2.5))
    (Transporte (origen "Marrakech") (destino "Lisboa")     (tipo Avion) (precio_persona 120.0) (horas_viaje 2.5))
    (Transporte (origen "Estambul")  (destino "Roma")       (tipo Avion) (precio_persona 110.0) (horas_viaje 2.5))
    (Transporte (origen "Estambul")  (destino "Viena")      (tipo Avion) (precio_persona 100.0) (horas_viaje 2.5))
    (Transporte (origen "Edimburgo") (destino "Amsterdam")  (tipo Avion) (precio_persona 90.0)  (horas_viaje 2.0))
    (Transporte (origen "Edimburgo") (destino "Paris")      (tipo Avion) (precio_persona 90.0)  (horas_viaje 2.0))
    (Transporte (origen "Dubrovnik") (destino "Roma")       (tipo Avion) (precio_persona 90.0)  (horas_viaje 2.0))
    ;; Vuelos de vuelta al origen
    (Transporte (origen "Paris")     (destino "Origen") (tipo Avion) (precio_persona 120.0) (horas_viaje 2.0))
    (Transporte (origen "Roma")      (destino "Origen") (tipo Avion) (precio_persona 130.0) (horas_viaje 2.5))
    (Transporte (origen "Amsterdam") (destino "Origen") (tipo Avion) (precio_persona 140.0) (horas_viaje 2.5))
    (Transporte (origen "Praga")     (destino "Origen") (tipo Avion) (precio_persona 110.0) (horas_viaje 2.5))
    (Transporte (origen "Viena")     (destino "Origen") (tipo Avion) (precio_persona 125.0) (horas_viaje 2.5))
    (Transporte (origen "Berlin")    (destino "Origen") (tipo Avion) (precio_persona 115.0) (horas_viaje 2.5))
    (Transporte (origen "Lisboa")    (destino "Origen") (tipo Avion) (precio_persona 100.0) (horas_viaje 2.5))
    (Transporte (origen "Barcelona") (destino "Origen") (tipo Avion) (precio_persona 80.0)  (horas_viaje 1.5))
    (Transporte (origen "Florencia") (destino "Origen") (tipo Avion) (precio_persona 120.0) (horas_viaje 2.0))
    (Transporte (origen "Estambul")  (destino "Origen") (tipo Avion) (precio_persona 160.0) (horas_viaje 3.5))
    (Transporte (origen "Edimburgo") (destino "Origen") (tipo Avion) (precio_persona 130.0) (horas_viaje 2.5))
    (Transporte (origen "Dubrovnik") (destino "Origen") (tipo Avion) (precio_persona 150.0) (horas_viaje 3.0))
    (Transporte (origen "Marrakech") (destino "Origen") (tipo Avion) (precio_persona 140.0) (horas_viaje 2.5))
    (Transporte (origen "Santorini") (destino "Origen") (tipo Avion) (precio_persona 160.0) (horas_viaje 3.5))
    (Transporte (origen "Reykjavik") (destino "Origen") (tipo Avion) (precio_persona 200.0) (horas_viaje 4.0))
    (Transporte (origen "Bali")      (destino "Origen") (tipo Avion) (precio_persona 650.0) (horas_viaje 14.0))
    (Transporte (origen "Tokio")     (destino "Origen") (tipo Avion) (precio_persona 700.0) (horas_viaje 12.0))
    (Transporte (origen "Nueva York")(destino "Origen") (tipo Avion) (precio_persona 500.0) (horas_viaje 9.0))
    (Transporte (origen "Bangkok")   (destino "Origen") (tipo Avion) (precio_persona 600.0) (horas_viaje 11.0))

    ;; Punto de entrada al sistema
    (fase inicio)
)


;; PREGUNTAS AL USUARIO

(defrule Iniciar_Sistema
    ?f <- (fase inicio)
    =>
    (retract ?f)
    (printout t "----------------------------------------------------------" crlf)
    (printout t "   BIENVENIDO A LA AGENCIA DE VIAJES AL FIN DEL MUNDO    " crlf)
    (printout t "      Y MAS ALLA - Sistema Experto de Recomendacion       " crlf)
    (printout t "----------------------------------------------------------" crlf)
    (printout t crlf)
    (assert (fase p1_composicion))
)

;; P1: Pregunta la composición del grupo.
(defrule P1_Composicion
    ?f <- (fase p1_composicion)
    =>
    (retract ?f)
    (printout t "1. Con quien viaja?" crlf)
    (printout t "   [1] Solo/a" crlf)
    (printout t "   [2] En pareja" crlf)
    (printout t "   [3] Familia" crlf)
    (printout t "   [4] Grupo de amigos" crlf)
    (printout t "   Opcion (1-4): ")
    (bind ?r (read))
    (bind ?comp (if (= ?r 1) then Solo
                 else (if (= ?r 2) then Pareja
                       else (if (= ?r 3) then Familia
                             else Grupo))))
    (assert (resp_composicion ?comp))
    (assert (fase p2_ninos))
)

;; P2a: Solo se pregunta por niños si el grupo es Familia o Grupo.
(defrule P2_Ninos_Aplica
    ?f <- (fase p2_ninos)
    (resp_composicion ?c&:(or (eq ?c Familia) (eq ?c Grupo)))
    =>
    (retract ?f)
    (printout t "2. Viaja con ninos menores de 12 anos? [s/n]: ")
    (bind ?r (read))
    (assert (resp_ninos (if (eq ?r s) then si else no)))
    (assert (fase p3_motivo))
)

;; P2b: Si viaja Solo o en Pareja, se asume automáticamente que no hay niños.
(defrule P2_Ninos_No_Aplica
    ?f <- (fase p2_ninos)
    (resp_composicion ?c&:(and (neq ?c Familia) (neq ?c Grupo)))
    =>
    (retract ?f)
    (assert (resp_ninos no))
    (assert (fase p3_motivo))
)

;; Pregunta independiente del tipo de grupo
(defrule P3_Motivo
    ?f <- (fase p3_motivo)
    =>
    (retract ?f)
    (printout t "3. Motivo principal del viaje?" crlf)
    (printout t "   [1] Romantico" crlf)
    (printout t "   [2] Cultural / Turismo" crlf)
    (printout t "   [3] Relax / Descanso" crlf)
    (printout t "   [4] Diversion / Fiesta" crlf)
    (printout t "   Opcion (1-4): ")
    (bind ?r (read))
    (bind ?mot (if (= ?r 1) then Romantico
                else (if (= ?r 2) then Cultural
                      else (if (= ?r 3) then Relax
                            else Diversion))))
    (assert (resp_motivo ?mot))
    (assert (fase p4_dias))
)

;; Pregunta independiente del tipo de grupo
(defrule P4_Dias
    ?f <- (fase p4_dias)
    =>
    (retract ?f)
    (printout t "4. Cuantos dias dura el viaje (minimo 3)? ")
    (bind ?d (read))
    (assert (resp_dias (max 3 (integer ?d))))
    (assert (fase p5_presupuesto))
)

;; Pregunta independiente del tipo de grupo
(defrule P5_Presupuesto
    ?f <- (fase p5_presupuesto)
    =>
    (retract ?f)
    (printout t "5. Presupuesto maximo por persona en euros (ej. 1500)? ")
    (bind ?p (read))
    (assert (resp_presupuesto (float ?p)))
    (assert (fase p6_transporte))
)

;; Pregunta independiente del tipo de grupo
(defrule P6_Transporte
    ?f <- (fase p6_transporte)
    =>
    (retract ?f)
    (printout t "6. Preferencia de transporte?" crlf)
    (printout t "   [1] Avion" crlf)
    (printout t "   [2] Tren (donde sea posible)" crlf)
    (printout t "   [3] Sin preferencia" crlf)
    (printout t "   Opcion (1-3): ")
    (bind ?r (read))
    (bind ?tr (if (= ?r 1) then Avion
               else (if (= ?r 2) then Tren
                     else Indiferente)))
    (assert (resp_transporte ?tr))
    (assert (fase p7_alojamiento))
)

;; Pregunta independiente del tipo de grupo
(defrule P7_Alojamiento
    ?f <- (fase p7_alojamiento)
    =>
    (retract ?f)
    (printout t "7. Categoria de alojamiento preferida?" crlf)
    (printout t "   [1] Economico (hostales)" crlf)
    (printout t "   [2] Estandar  (hoteles 3*)" crlf)
    (printout t "   [3] Lujo      (hoteles 4*-5*)" crlf)
    (printout t "   Opcion (1-3): ")
    (bind ?r (read))
    (bind ?cat (if (= ?r 1) then Economico
                else (if (= ?r 2) then Estandar
                      else Lujo)))
    (assert (resp_alojamiento ?cat))
    (printout t crlf)
    (printout t "Gracias. Calculando sus opciones de viaje..." crlf)
    (printout t crlf)
    (assert (fase crear_usuario))
)


;; CREACIÓN DEL HECHO USUARIO

;; Consolida todas las respuestas (resp_X) en un único hecho Usuario estructurado.
;; Solo dispara cuando los 7 hechos de respuesta están presentes simultáneamente.
(defrule Crear_Usuario
    ?f <- (fase crear_usuario)
    (resp_motivo      ?mot)
    (resp_composicion ?comp)
    (resp_ninos       ?nin)
    (resp_dias        ?dias)
    (resp_presupuesto ?presup)
    (resp_transporte  ?trans)
    (resp_alojamiento ?cat)
    =>
    (retract ?f)
    (assert (Usuario
        (motivo          ?mot)
        (composicion     ?comp)
        (con_ninos       ?nin)
        (dias_totales    ?dias)
        (presupuesto_max ?presup)
        (transporte_pref ?trans)
        (categoria_aloj  ?cat)
    ))
    (assert (fase deduccion))
)


;; DEDUCIR PERFIL

;; Regla: viaje romántico con niños -> destinos culturales/familiares
(defrule Deducir_Ajuste_Romantico_Ninos
    (fase deduccion)
    (Usuario (motivo Romantico) (con_ninos si))
    =>
    (assert (motivo_efectivo Cultural))
    (printout t "[Deduccion] Viaje romantico con ninos -> ajustado a Cultural." crlf)
)

;; Si no aplica el ajuste anterior, el motivo efectivo es el declarado.
(defrule Deducir_Motivo_Sin_Cambio
    (fase deduccion)
    (Usuario (motivo ?mot) (con_ninos ?n))
    (not (and (eq ?mot Romantico) (eq ?n si)))
    =>
    (assert (motivo_efectivo ?mot))
)

;; Deducir distancia del viaje
;; Radio Corto: <= 5 días. No vale la pena volar >3h para estancias muy cortas.
(defrule Deducir_Radio_Corto
    (fase deduccion)
    (Usuario (dias_totales ?d&:(<= ?d 5)))
    =>
    (assert (radio_viaje Corto))
)

;; Radio Medio: 6-10 días. Permite destinos a distancia Media
(defrule Deducir_Radio_Medio
    (fase deduccion)
    (Usuario (dias_totales ?d&:(and (> ?d 5) (<= ?d 10))))
    =>
    (assert (radio_viaje Medio))
)

;; Radio Largo: >10 días. Permite destinos lejanos
(defrule Deducir_Radio_Largo
    (fase deduccion)
    (Usuario (dias_totales ?d&:(> ?d 10)))
    =>
    (assert (radio_viaje Largo))
)

;; Deducir número de ciudades. 
;; 1 ciudad, <= 4 dias
(defrule Deducir_Max_Ciudades_1
    (fase deduccion)
    (Usuario (dias_totales ?d&:(<= ?d 4)))
    =>
    (assert (max_ciudades 1))
)

;; 2 ciudades, 5-8 dias
(defrule Deducir_Max_Ciudades_2
    (fase deduccion)
    (Usuario (dias_totales ?d&:(and (> ?d 4) (<= ?d 8))))
    =>
    (assert (max_ciudades 2))
)

;; 3 ciudades, 9-13 dias
(defrule Deducir_Max_Ciudades_3
    (fase deduccion)
    (Usuario (dias_totales ?d&:(and (> ?d 8) (<= ?d 13))))
    =>
    (assert (max_ciudades 3))
)

;; 4 ciudades, >13 dias
(defrule Deducir_Max_Ciudades_4
    (fase deduccion)
    (Usuario (dias_totales ?d&:(> ?d 13)))
    =>
    (assert (max_ciudades 4))
)

;; Nivel de presupuesto
;; Presupuesto bajo, <800 eur
(defrule Deducir_Presupuesto_Bajo
    (fase deduccion)
    (Usuario (presupuesto_max ?p&:(<= ?p 800.0)))
    =>
    (assert (presupuesto_nivel Bajo))
)

;; Presupuesto medio, 800-2500 eur
(defrule Deducir_Presupuesto_Medio
    (fase deduccion)
    (Usuario (presupuesto_max ?p&:(and (> ?p 800.0) (<= ?p 2500.0))))
    =>
    (assert (presupuesto_nivel Medio))
)

;; Presupuesto alto, > 2500 eur
(defrule Deducir_Presupuesto_Alto
    (fase deduccion)
    (Usuario (presupuesto_max ?p&:(> ?p 2500.0)))
    =>
    (assert (presupuesto_nivel Alto))
)

;; Consolidar el Perfil cuando todas las preguntas hayan sido contestadas
(defrule Consolidar_Perfil
    ?f <- (fase deduccion)
    (motivo_efectivo   ?mot)
    (radio_viaje       ?radio)
    (max_ciudades      ?mc)
    (presupuesto_nivel ?pnivel)
    (Usuario           (dias_totales ?dias))
    =>
    (retract ?f)
    (bind ?dpc (max 2 (div ?dias ?mc)))
    (assert (Perfil
        (motivo_efectivo   ?mot)
        (max_ciudades      ?mc)
        (dias_por_ciudad   ?dpc)
        (radio_viaje       ?radio)
        (presupuesto_nivel ?pnivel)
    ))
    (printout t "[Perfil] motivo=" ?mot " max_ciudades=" ?mc
              " dias/ciudad=" ?dpc " radio=" ?radio " presup=" ?pnivel crlf)
    (printout t crlf)
    (assert (fase construir_plan_1))
)


;; PLAN 1

;; Inicializa el acumulador EstadoPlan y lanza la búsqueda de la primera ciudad.
(defrule Iniciar_Plan1
    ?f <- (fase construir_plan_1)
    =>
    (retract ?f)
    (assert (PlanViaje (plan_id 1) (estado Construyendo)))
    (assert (EstadoPlan (plan_id 1) (dias_usados 0) (coste_acum 0.0)
                        (orden_actual 0) (ultima_ciudad "Origen")))
    (assert (fase elegir_ciudad1_p1))
)

;; La primera ciudad del plan 1 coincide con el motivo del perfil
(defrule Elegir_Ciudad1_P1
    ?f  <- (fase elegir_ciudad1_p1)
    ?ep <- (EstadoPlan (plan_id 1) (dias_usados ?du) (coste_acum ?ca)
                       (orden_actual ?oa) (ultima_ciudad "Origen"))
    (Perfil (motivo_efectivo ?mot) (radio_viaje ?radio) (dias_por_ciudad ?dpc))
    (Usuario (con_ninos ?nin) (categoria_aloj ?cat)
             (presupuesto_max ?pmax) (transporte_pref ?tpref))
    (Ciudad (nombre ?c) (tematica ?t&:(eq ?t ?mot))
            (distancia ?dist&:(or (eq ?radio Largo)
                                  (and (eq ?radio Medio) (neq ?dist Larga))
                                  (and (eq ?radio Corto) (eq ?dist Corta))))
            (apta_ninos ?an&:(or (eq ?nin no) (eq ?an si))))
    (not (CiudadUsada (plan_id 1) (ciudad ?c)))
    (Transporte (origen "Origen") (destino ?c)
                (tipo ?tt&:(or (eq ?tpref Indiferente) (eq ?tt ?tpref)))
                (precio_persona ?pt))
    (Alojamiento (ciudad ?c) (categoria ?cat) (precio_noche ?pn)
                 (nombre ?na) (apto_ninos ?an2&:(or (eq ?nin no) (eq ?an2 si))))
    (test (<= (+ ?ca ?pt (* ?pn ?dpc)) ?pmax))
    =>
    (retract ?f ?ep)
    (assert (CiudadUsada (plan_id 1) (ciudad ?c)))
    (assert (Etapa (plan_id 1) (orden 1) (ciudad ?c) (dias ?dpc)
                   (nombre_alojamiento ?na) (tipo_transporte ?tt)
                   (coste_aloj (* ?pn ?dpc)) (coste_transporte ?pt)))
    (assert (EstadoPlan (plan_id 1)
                        (dias_usados ?dpc)
                        (coste_acum (+ ?ca ?pt (* ?pn ?dpc)))
                        (orden_actual 1)
                        (ultima_ciudad ?c)))
    (printout t "[Plan 1] Etapa 1: " ?c " (" ?dpc " dias, " ?tt ")" crlf)
    (assert (fase ampliar_p1))
)

;; Amplía el plan con ciudades adicionales conectadas por transporte desde la
;; última ciudad visitada. Condiciones de parada:
;;   - ?oa >= max_ciudades: ya se alcanzó el máximo de ciudades
;;   - ?du >= dias_totales - 1: no quedan días suficientes
;;   - coste acumulado > 90% del presupuesto: reserva para el vuelo de vuelta
;; Se retracta EstadoPlan y se reaserta actualizado (patrón acumulador).
(defrule Ampliar_P1
    ?f  <- (fase ampliar_p1)
    ?ep <- (EstadoPlan (plan_id 1) (dias_usados ?du) (coste_acum ?ca)
                       (orden_actual ?oa) (ultima_ciudad ?uc))
    (Perfil (max_ciudades ?mc) (dias_por_ciudad ?dpc))
    (Usuario (con_ninos ?nin) (categoria_aloj ?cat)
             (presupuesto_max ?pmax) (dias_totales ?dtotal)
             (transporte_pref ?tpref))
    (test (< ?oa ?mc))
    (test (< ?du (- ?dtotal 1)))
    (Transporte (origen ?uc) (destino ?c)
                (tipo ?tt&:(or (eq ?tpref Indiferente) (eq ?tt ?tpref)))
                (precio_persona ?pt))
    (Ciudad (nombre ?c) (apta_ninos ?an&:(or (eq ?nin no) (eq ?an si))))
    (not (CiudadUsada (plan_id 1) (ciudad ?c)))
    (Alojamiento (ciudad ?c) (categoria ?cat) (precio_noche ?pn)
                 (nombre ?na) (apto_ninos ?an2&:(or (eq ?nin no) (eq ?an2 si))))
    (bind ?dias_nueva (max 2 (min ?dpc (- ?dtotal ?du 1))))
    (test (> ?dias_nueva 0))
    (test (<= (+ ?ca ?pt (* ?pn ?dias_nueva)) (* ?pmax 0.9)))
    =>
    (retract ?f ?ep)
    (bind ?no (+ ?oa 1))
    (assert (CiudadUsada (plan_id 1) (ciudad ?c)))
    (assert (Etapa (plan_id 1) (orden ?no) (ciudad ?c) (dias ?dias_nueva)
                   (nombre_alojamiento ?na) (tipo_transporte ?tt)
                   (coste_aloj (* ?pn ?dias_nueva)) (coste_transporte ?pt)))
    (assert (EstadoPlan (plan_id 1)
                        (dias_usados (+ ?du ?dias_nueva))
                        (coste_acum (+ ?ca ?pt (* ?pn ?dias_nueva)))
                        (orden_actual ?no)
                        (ultima_ciudad ?c)))
    (printout t "[Plan 1] Etapa " ?no ": " ?c " (" ?dias_nueva " dias, " ?tt ")" crlf)
    (assert (fase ampliar_p1))
)

;; Cerramos el plan 1 y añadimos el vuelo de vuelta al origen
(defrule Cerrar_P1
    ?f  <- (fase ampliar_p1)
    ?ep <- (EstadoPlan (plan_id 1) (dias_usados ?du) (coste_acum ?ca)
                       (ultima_ciudad ?uc))
    ?pv <- (PlanViaje (plan_id 1))
    (Transporte (origen ?uc) (destino "Origen") (tipo Avion) (precio_persona ?pv2))
    =>
    (retract ?f ?ep)
    (bind ?coste_final (+ ?ca ?pv2))
    (modify ?pv (coste_total ?coste_final) (num_dias ?du) (estado Completo))
    (printout t "[Plan 1] CERRADO - Coste: " ?coste_final " eur | Dias: " ?du crlf)
    (printout t crlf)
    (assert (fase construir_plan_2))
)

;; Sin solución para el plan 1
(defrule SinSolucion_P1
    ?f <- (fase elegir_ciudad1_p1)
    (not (Etapa (plan_id 1)))
    =>
    (retract ?f)
    (printout t crlf)
    (printout t "-------------------------------------------------------" crlf)
    (printout t " Lo sentimos: no encontramos ningun viaje que cumpla   " crlf)
    (printout t " sus restricciones de presupuesto, dias y preferencias." crlf)
    (printout t " Pruebe a aumentar el presupuesto o los dias de viaje. " crlf)
    (printout t "-------------------------------------------------------" crlf)
    (assert (fase fin))
)


;; CONSTRUCCIÓN DEL PLAN 2 (diferente del 1)

(defrule Iniciar_Plan2
    ?f <- (fase construir_plan_2)
    =>
    (retract ?f)
    (assert (PlanViaje (plan_id 2) (estado Construyendo)))
    (assert (EstadoPlan (plan_id 2) (dias_usados 0) (coste_acum 0.0)
                        (orden_actual 0) (ultima_ciudad "Origen")))
    (assert (fase elegir_ciudad1_p2))
)

;; Plan 2: misma lógica que Plan 1 pero filtra además las ciudades del Plan 1,
;; garantizando que ambas opciones sean genuinamente diferentes.
(defrule Elegir_Ciudad1_P2
    ?f  <- (fase elegir_ciudad1_p2)
    ?ep <- (EstadoPlan (plan_id 2) (dias_usados ?du) (coste_acum ?ca)
                       (orden_actual ?oa) (ultima_ciudad "Origen"))
    (Perfil (radio_viaje ?radio) (dias_por_ciudad ?dpc))
    (Usuario (con_ninos ?nin) (categoria_aloj ?cat)
             (presupuesto_max ?pmax) (transporte_pref ?tpref))
    (Ciudad (nombre ?c)
            (distancia ?dist&:(or (eq ?radio Largo)
                                  (and (eq ?radio Medio) (neq ?dist Larga))
                                  (and (eq ?radio Corto) (eq ?dist Corta))))
            (apta_ninos ?an&:(or (eq ?nin no) (eq ?an si))))
    (not (CiudadUsada (plan_id 1) (ciudad ?c)))
    (not (CiudadUsada (plan_id 2) (ciudad ?c)))
    (Transporte (origen "Origen") (destino ?c)
                (tipo ?tt&:(or (eq ?tpref Indiferente) (eq ?tt ?tpref)))
                (precio_persona ?pt))
    (Alojamiento (ciudad ?c) (categoria ?cat) (precio_noche ?pn)
                 (nombre ?na) (apto_ninos ?an2&:(or (eq ?nin no) (eq ?an2 si))))
    (test (<= (+ ?ca ?pt (* ?pn ?dpc)) ?pmax))
    =>
    (retract ?f ?ep)
    (assert (CiudadUsada (plan_id 2) (ciudad ?c)))
    (assert (Etapa (plan_id 2) (orden 1) (ciudad ?c) (dias ?dpc)
                   (nombre_alojamiento ?na) (tipo_transporte ?tt)
                   (coste_aloj (* ?pn ?dpc)) (coste_transporte ?pt)))
    (assert (EstadoPlan (plan_id 2)
                        (dias_usados ?dpc)
                        (coste_acum (+ ?ca ?pt (* ?pn ?dpc)))
                        (orden_actual 1)
                        (ultima_ciudad ?c)))
    (printout t "[Plan 2] Etapa 1: " ?c " (" ?dpc " dias, " ?tt ")" crlf)
    (assert (fase ampliar_p2))
)

(defrule Ampliar_P2
    ?f  <- (fase ampliar_p2)
    ?ep <- (EstadoPlan (plan_id 2) (dias_usados ?du) (coste_acum ?ca)
                       (orden_actual ?oa) (ultima_ciudad ?uc))
    (Perfil (max_ciudades ?mc) (dias_por_ciudad ?dpc))
    (Usuario (con_ninos ?nin) (categoria_aloj ?cat)
             (presupuesto_max ?pmax) (dias_totales ?dtotal)
             (transporte_pref ?tpref))
    (test (< ?oa ?mc))
    (test (< ?du (- ?dtotal 1)))
    (Transporte (origen ?uc) (destino ?c)
                (tipo ?tt&:(or (eq ?tpref Indiferente) (eq ?tt ?tpref)))
                (precio_persona ?pt))
    (Ciudad (nombre ?c) (apta_ninos ?an&:(or (eq ?nin no) (eq ?an si))))
    (not (CiudadUsada (plan_id 1) (ciudad ?c)))
    (not (CiudadUsada (plan_id 2) (ciudad ?c)))
    (Alojamiento (ciudad ?c) (categoria ?cat) (precio_noche ?pn)
                 (nombre ?na) (apto_ninos ?an2&:(or (eq ?nin no) (eq ?an2 si))))
    (bind ?dias_nueva (max 2 (min ?dpc (- ?dtotal ?du 1))))
    (test (> ?dias_nueva 0))
    (test (<= (+ ?ca ?pt (* ?pn ?dias_nueva)) (* ?pmax 0.9)))
    =>
    (retract ?f ?ep)
    (bind ?no (+ ?oa 1))
    (assert (CiudadUsada (plan_id 2) (ciudad ?c)))
    (assert (Etapa (plan_id 2) (orden ?no) (ciudad ?c) (dias ?dias_nueva)
                   (nombre_alojamiento ?na) (tipo_transporte ?tt)
                   (coste_aloj (* ?pn ?dias_nueva)) (coste_transporte ?pt)))
    (assert (EstadoPlan (plan_id 2)
                        (dias_usados (+ ?du ?dias_nueva))
                        (coste_acum (+ ?ca ?pt (* ?pn ?dias_nueva)))
                        (orden_actual ?no)
                        (ultima_ciudad ?c)))
    (printout t "[Plan 2] Etapa " ?no ": " ?c " (" ?dias_nueva " dias, " ?tt ")" crlf)
    (assert (fase ampliar_p2))
)

(defrule Cerrar_P2
    ?f  <- (fase ampliar_p2)
    ?ep <- (EstadoPlan (plan_id 2) (dias_usados ?du) (coste_acum ?ca)
                       (ultima_ciudad ?uc))
    ?pv <- (PlanViaje (plan_id 2))
    (Transporte (origen ?uc) (destino "Origen") (tipo Avion) (precio_persona ?pv2))
    =>
    (retract ?f ?ep)
    (bind ?coste_final (+ ?ca ?pv2))
    (modify ?pv (coste_total ?coste_final) (num_dias ?du) (estado Completo))
    (printout t "[Plan 2] CERRADO - Coste: " ?coste_final " eur | Dias: " ?du crlf)
    (printout t crlf)
    (assert (fase asignar_visitas))
)

;; Sin segunda alternativa de viaje
(defrule SinSolucion_P2
    ?f <- (fase elegir_ciudad1_p2)
    (not (Etapa (plan_id 2)))
    =>
    (retract ?f)
    (printout t "[Aviso] No se pudo generar una segunda alternativa de viaje." crlf)
    (assert (fase asignar_visitas))
)


;; ASIGNACIÓN DE LUGARES A VISITAR

;; Asigna lugares de visita a cada etapa por afinidad temática con el motivo efectivo.
;; Cultural y Naturaleza se consideran de interés universal y siempre se incluyen.
;; El límite de 3 visitas por ciudad se implementa con negación anidada:
;; la regla no dispara si ya existen 3 visitas distintas para esa ciudad y plan.
(defrule Asignar_Visita
    (fase asignar_visitas)
    (Perfil (motivo_efectivo ?mot))
    (Etapa (plan_id ?pid) (ciudad ?c))
    (LugarVisita (nombre ?lv) (ciudad ?c) (interes ?int))
    (test (or (eq ?int ?mot) (eq ?int Cultural) (eq ?int Naturaleza)))
    (not (VisitaAsignada (plan_id ?pid) (ciudad ?c) (lugar ?lv)))
    ;; Límite de 3 visitas por ciudad
    (not (and (VisitaAsignada (plan_id ?pid) (ciudad ?c) (lugar ?a))
              (VisitaAsignada (plan_id ?pid) (ciudad ?c) (lugar ?b))
              (VisitaAsignada (plan_id ?pid) (ciudad ?c) (lugar ?cc))
              (test (and (neq ?a ?lv) (neq ?b ?lv) (neq ?cc ?lv)
                         (neq ?a ?b)  (neq ?a ?cc) (neq ?b ?cc)))))
    =>
    (assert (VisitaAsignada (plan_id ?pid) (ciudad ?c) (lugar ?lv)))
)

;; Cuando no quedan más visitas por asignar, pasa a la fase de presentación.
(defrule Fin_Visitas
    ?f <- (fase asignar_visitas)
    =>
    (retract ?f)
    (assert (fase presentar_resultados))
)

;; RESULTADOS

(defrule Presentar_Cabecera
    ?f <- (fase presentar_resultados)
    =>
    (retract ?f)
    (printout t "----------------------------------------------------------" crlf)
    (printout t "           SUS RECOMENDACIONES DE VIAJE                  " crlf)
    (printout t "----------------------------------------------------------" crlf)
    (assert (fase mostrar_plan 1))
)

(defrule Mostrar_Cabecera_Plan
    ?f <- (fase mostrar_plan ?pid)
    (PlanViaje (plan_id ?pid) (coste_total ?ct) (num_dias ?nd) (estado Completo))
    =>
    (retract ?f)
    (printout t crlf)
    (printout t ">>> OPCION " ?pid " <<<" crlf)
    (printout t "    Duracion total   : " ?nd " dias" crlf)
    (printout t "    Coste por persona: " ?ct " euros" crlf)
    (printout t crlf)
    (assert (fase mostrar_etapas ?pid 1))
)

(defrule Mostrar_Etapa
    ?f <- (fase mostrar_etapas ?pid ?ord)
    (Etapa (plan_id ?pid) (orden ?ord) (ciudad ?c) (dias ?d)
           (nombre_alojamiento ?na) (tipo_transporte ?tt)
           (coste_aloj ?ca) (coste_transporte ?ct))
    =>
    (retract ?f)
    (printout t "  Etapa " ?ord ": " ?c crlf)
    (printout t "    Transporte llegada: " ?tt crlf)
    (printout t "    Dias de estancia  : " ?d crlf)
    (printout t "    Alojamiento       : " ?na crlf)
    (printout t "    Coste transporte  : " ?ct " eur" crlf)
    (printout t "    Coste alojamiento : " ?ca " eur" crlf)
    (printout t "    Lugares a visitar :" crlf)
    (do-for-all-facts ((?v VisitaAsignada))
        (and (= ?v:plan_id ?pid) (eq ?v:ciudad ?c))
        (printout t "      - " ?v:lugar crlf))
    (assert (fase mostrar_etapas ?pid (+ ?ord 1)))
)

(defrule Fin_Etapas
    ?f <- (fase mostrar_etapas ?pid ?ord)
    (not (Etapa (plan_id ?pid) (orden ?ord)))
    =>
    (retract ?f)
    (if (= ?pid 1)
     then (assert (fase mostrar_plan 2))
     else (assert (fase mostrar_preferencias)))
)

;; Si el plan 2 no existe vamos a preferencias
(defrule Saltar_Plan2_Inexistente
    ?f <- (fase mostrar_plan 2)
    (not (PlanViaje (plan_id 2) (estado Completo)))
    =>
    (retract ?f)
    (assert (fase mostrar_preferencias))
)

(defrule Mostrar_Preferencias
    ?f <- (fase mostrar_preferencias)
    (Usuario (motivo ?mot) (composicion ?comp) (con_ninos ?nin)
             (dias_totales ?d) (presupuesto_max ?p)
             (categoria_aloj ?cat) (transporte_pref ?tr))
    (Perfil  (motivo_efectivo ?mef) (radio_viaje ?radio))
    =>
    (retract ?f)
    (printout t crlf)
    (printout t "--- PERFIL Y PREFERENCIAS ---" crlf)
    (printout t "    Motivo solicitado   : " ?mot crlf)
    (printout t "    Motivo aplicado     : " ?mef crlf)
    (printout t "    Composicion         : " ?comp crlf)
    (printout t "    Con ninos           : " ?nin crlf)
    (printout t "    Dias disponibles    : " ?d crlf)
    (printout t "    Presupuesto max/p   : " ?p " euros" crlf)
    (printout t "    Alojamiento         : " ?cat crlf)
    (printout t "    Transporte preferido: " ?tr crlf)
    (printout t "    Radio de viaje      : " ?radio crlf)
    (printout t crlf)
    (assert (fase fin))
)