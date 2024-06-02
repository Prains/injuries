local injury_replay_time = 11

local soundPath = 'injury_effects/heartbeat.wav'

local last_health = 100 -- Начальное значение здоровья
local pulse_alpha = 0
local pulse_direction = 1
local effect_duration = 0

local function AddInjuryEffects()
    local health = LocalPlayer():Health()

    -- Очищаем эффекты только при изменении состояния здоровья
    if (last_health > 40 and health <= 40) or (last_health <= 40 and health > 40) then
        hook.Remove("HUDPaint", "DrawInjuryEffects")
        timer.Remove("RepeatInjurySound")
        pulse_alpha = 0
        pulse_direction = 1
        effect_duration = 0
    end

    if health <= 40 then
        -- Единый эффект при здоровье <= 40
        if (effect_duration == 0) then
            surface.PlaySound(soundPath)
            effect_duration = CurTime() + injury_replay_time -- Устанавливаем продолжительность эффекта на 11 секунд
        end

        hook.Add("HUDPaint", "DrawInjuryEffects", function()
            if CurTime() > effect_duration then
                -- Темно-красное покрытие после завершения 11 секунд
                pulse_alpha = 100
            else
                -- Пульсирующий эффект с замедленной скоростью
                if pulse_direction == 1 then
                    pulse_alpha = pulse_alpha + 1
                    if pulse_alpha >= 100 then
                        pulse_direction = -1
                    end
                else
                    pulse_alpha = pulse_alpha - 1
                    if pulse_alpha <= 0 then
                        pulse_direction = 1
                    end
                end
            end

            -- Градиент от красного к темно-красному
            local red = 255
            local green = 0
            local blue = 0
            local alpha = (pulse_alpha / 100) * 150 + 50 -- Прозрачность от 50 до 200

            surface.SetDrawColor(red, green, blue, alpha)
            surface.DrawRect(0, 0, ScrW(), ScrH())
        end)
    end

    last_health = health
end

local function PlayInjuryWalkingSound(player, pos, foot, soundName, volume, rf)
    if player:Health() <= 40 then
        player:EmitSound(walkingSoundPath)
        return true -- чтобы предотвратить воспроизведение стандартного звука шага
    end
end

hook.Add("PlayerFootstep", "InjuryWalkingSound", PlayInjuryWalkingSound)

hook.Add("Think", "CheckHealthInjuryEffects", AddInjuryEffects)
