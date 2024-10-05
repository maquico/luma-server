set check_function_bodies = off;

CREATE OR REPLACE FUNCTION public.buy_with_gems_transaction(p_usuario_id uuid, p_recompensa_id integer, p_precio numeric)
 RETURNS TABLE(recompensa_id integer, usuario_id uuid, gemas_restantes integer, total_compras_actualizadas integer, cantidad_comprada integer)
 LANGUAGE plpgsql
AS $function$
BEGIN
    -- Insertar el historial de recompensas
    INSERT INTO Historial_Recompensas (
        Recompensa_ID, Usuario_ID, cantidadComprada, precioComprado, fechaRegistro
    ) 
    VALUES (
        p_recompensa_id, p_usuario_id, 1, p_precio, NOW()
    );

    -- Actualizar el total de compras en la tabla de Recompensas
    UPDATE Recompensas
    SET totalCompras = totalCompras + 1
    WHERE Recompensa_ID = p_recompensa_id;

    -- Descontar las gemas del usuario en la tabla Miembro_Proyecto
    UPDATE Miembro_Proyecto
    SET gemas = gemas - p_precio
    WHERE Usuario_ID = p_usuario_id
    AND Proyecto_ID = (SELECT Proyecto_ID FROM Recompensas WHERE Recompensa_ID = p_recompensa_id);

    -- Retornar los datos actualizados
    RETURN QUERY
    SELECT 
        r.Recompensa_ID,
        mp.Usuario_ID,
        mp.gemas,
        r.totalCompras,
        hr.cantidadComprada
    FROM 
        Recompensas r
        JOIN Miembro_Proyecto mp ON mp.Proyecto_ID = r.Proyecto_ID
        JOIN Historial_Recompensas hr ON hr.Usuario_ID = mp.Usuario_ID
    WHERE 
        r.Recompensa_ID = p_recompensa_id
        AND hr.Usuario_ID = p_usuario_id
    ORDER BY hr.fechaRegistro DESC
    LIMIT 1;

END;
$function$
;


