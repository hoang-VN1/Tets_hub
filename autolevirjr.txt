if _G.AutoLeviathanFull_Loaded then
    local env = (getgenv and getgenv()) or _G
    if not env.ForceReload then
        print("[Auto Leviathan] Ya hay una instancia cargada. Para recargar: ejecuta  getgenv().ForceReload = true  y vuelve a ejecutar el script.")
        return
    end
    env.ForceReload = false
    print("[Auto Leviathan] Recarga forzada: la instancia anterior (menu y bucles) puede seguir activa.")
end
_G.AutoLeviathanFull_Loaded = true
repeat task.wait() until game:IsLoaded() and game:GetService("Players").LocalPlayer
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local RS = game:GetService("ReplicatedStorage")
local TweenService = game:GetService("TweenService")
local HttpService = game:GetService("HttpService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local LocalPlayer = Players.LocalPlayer
local Remote = RS:FindFirstChild("Remotes")
local CommF = Remote and Remote:FindFirstChild("CommF_")
local T, ModeDisplay
T, ModeDisplay = (function()
    local LANGUAGE_LABELS = { "English", "Español", "中文" }
    local LANG_CODE = { ["English"] = "en", ["Español"] = "es", ["中文"] = "zh" }
    local function NormalizeLanguage(value)
        if value == nil then
            return nil
        end
        local v = tostring(value)
        if LANG_CODE[v] then
            return v
        end
        local low = v:lower()
        if low == "chinese" or low == "zh" or low == "cn" or low == "china" then
            return "中文"
        end
        if low == "spanish" or low == "es" or low == "español" then
            return "Español"
        end
        if low == "english" or low == "en" then
            return "English"
        end
        return nil
    end
    local function LanguageCode()
        return LANG_CODE[_G.Language] or "en"
    end
    local LangTable = {
        ["ann.copied"] = { en = "DC link copied", es = "Enlace de Discord copiado", zh = "已复制 DC 链接" },
        ["ann.copy"] = { en = "Copy DC Link", es = "Copiar enlace de Discord", zh = "复制 DC 链接" },
        ["ann.dc"] = { en = "DC Server", es = "Servidor de Discord", zh = "DC 服务器" },
        ["anti.draco"] = { en = "Anti Draco Aura", es = "Anti Draco Aura", zh = "反 Draco Aura" },
        ["anti.draco.desc"] = { en = "Raises the RemoteEvent invocation size limit", es = "Sube el límite de tamaño de los RemoteEvent", zh = "提高 RemoteEvent 调用大小限制" },
        ["auto.buso"] = { en = "Auto Buso (Haki)", es = "Buso automático (Haki)", zh = "自动霸气 (Buso)" },
        ["auto.fast"] = { en = "Auto Fast Mode", es = "Modo rápido automático", zh = "自动快速模式" },
        ["auto.fast.desc"] = { en = "Enables Fast Mode and reduces map materials", es = "Activa el modo rápido del juego y reduce los materiales del mapa", zh = "启用游戏快速模式并降低地图材质" },
        ["auto.full"] = { en = "Auto Leviathan Full", es = "Leviathan automático completo", zh = "全自动利维坦" },
        ["auto.ken"] = { en = "Auto Ken (Observation)", es = "Ken automático (Observacion)", zh = "自动见闻色 (Ken)" },
        ["auto.ken.desc"] = { en = "Auto-enables Observation Haki every 5s", es = "Activa la Observacion cada 5 segundos", zh = "每5秒自动开启见闻色霸气" },
        ["auto.v3"] = { en = "Auto V3", es = "V3 automático", zh = "自动 V3" },
        ["auto.v3.desc"] = { en = "Auto activate race V3", es = "Activa la habilidad V3 de la raza", zh = "自动开启种族 V3" },
        ["auto.v4"] = { en = "Auto V4", es = "V4 automático", zh = "自动 V4" },
        ["auto.v4.desc"] = { en = "Auto activate race V4 when full", es = "Activa la V4 cuando la energía esta llena", zh = "能量满自动开启种族 V4" },
        ["boat.height"] = { en = "Boat Height", es = "Altura del barco", zh = "船高度" },
        ["boat.height.desc"] = { en = "Locked boat Y height while travelling (30–500)", es = "Altura Y fija del barco al navegar (30-500)", zh = "航行时锁定船的 Y 高度（30–500）" },
        ["boat.speed"] = { en = "Boat Speed", es = "Velocidad del barco", zh = "船速度" },
        ["boat.speed.desc"] = { en = "Boat and cruise speed (50–500). The return trip to Tiki stays fixed at 120", es = "Velocidad al navegar y patrullar (50-500). La vuelta a Tiki va fija a 120", zh = "开船与巡航速度（50–500）；返航 Tiki 固定 120，不受此项影响" },
        ["bribe.cd"] = { en = "On Cooldown", es = "En espera", zh = "CD中" },
        ["bribe.done"] = { en = "Complete", es = "Completado", zh = "已完毕" },
        ["bribe.unknown"] = { en = "Unknown", es = "Desconocido", zh = "未知" },
        ["cruise.return"] = { en = "Return after 10 km", es = "Volver tras 10 km", zh = "航行10km后返回" },
        ["cruise.return.desc"] = { en = "On: cruises back and forth between points A and B. Off: sails straight ahead without turning around", es = "Activado: va y vuelve entre los puntos A y B. Desactivado: navega en linea recta sin dar la vuelta", zh = "开启后A/B两点来回巡航；关闭则一直向前航行，不折返" },
        ["craft.auto"] = { en = "Auto Craft", es = "Fabricar automáticamente", zh = "自动制作" },
        ["craft.auto.desc"] = { en = "Auto craft scrolls of selected quality", es = "Fabrica pergaminos de la calidad elegida", zh = "开启后按所选品质自动制作卷轴" },
        ["craft.miss.item"] = { en = "Missing {k} ({a}/{b})", es = "Falta {k} ({a}/{b})", zh = "缺 {k} ({a}/{b})" },
        ["craft.miss.progress"] = { en = "Missing progress {k} ({a}/{b})", es = "Falta progreso {k} ({a}/{b})", zh = "进度缺 {k} ({a}/{b})" },
        ["craft.quality"] = { en = "Scroll Quality", es = "Calidad del pergamino", zh = "选择卷轴品质" },
        ["craft.quality.desc"] = { en = "Auto craft scrolls when materials ready", es = "Fabrica cuando tengas materiales y progreso", zh = "材料/进度够时自动制作卷轴" },
        ["craft.roll"] = { en = "Auto Roll Fruit", es = "Girar fruta automáticamente", zh = "自动抽果实" },
        ["craft.status"] = { en = "Status", es = "Estado", zh = "状态" },
        ["craft.status.done"] = { en = "{name}: Crafted", es = "{name}: fabricado", zh = "{name}: 已制作" },
        ["craft.status.error"] = { en = "Failed to get craft data", es = "No se pudieron obtener los datos de fabricación", zh = "获取制作数据失败" },
        ["craft.status.miss"] = { en = "{name}: {miss}", es = "{name}: {miss}", zh = "{name}: {miss}" },
        ["craft.status.noRecipe"] = { en = "Recipe not found: {name}", es = "Receta no encontrada: {name}", zh = "配方不存在: {name}" },
        ["craft.status.none"] = { en = "Off", es = "Desactivado", zh = "未开启" },
        ["craft.store"] = { en = "Auto Store Fruits", es = "Guardar frutas automáticamente", zh = "自动存果实" },
        ["detail.bribe"] = { en = "Spy Bribe", es = "Soborno al espía", zh = "间谍贿赂" },
        ["detail.follow"] = { en = "Following", es = "Siguiendo a", zh = "跟随" },
        ["detail.no.boat"] = { en = "No boat", es = "Sin barco", zh = "船不存在" },
        ["detail.no.captain"] = { en = "No captain selected", es = "Sin capitán seleccionado", zh = "未选择队长" },
        ["detail.not.seated"] = { en = "Not seated", es = "Sin asiento", zh = "未坐船" },
        ["detail.seat"] = { en = "Current Seat", es = "Asiento actual", zh = "当前座位" },
        ["detail.teammates"] = { en = "Teammates On Board", es = "Compañeros a bordo", zh = "队友上船" },
        ["dragon.farm"] = { en = "Dragonstorm for Farming", es = "Usar Dragonstorm al farmear", zh = "刷海使用龙炮" },
        ["dragon.farm.desc"] = { en = "Use Dragonstorm for sea events (not Leviathan)", es = "Usa Dragonstorm en los eventos marinos (no en el Leviathan)", zh = "海上事件用 Dragonstorm 打（利维坦不用）" },
        ["dragon.leviathan"] = { en = "Dragonstorm vs Leviathan", es = "Dragonstorm contra el Leviathan", zh = "龙炮打利维坦" },
        ["dragon.leviathan.desc"] = { en = "Shoot Leviathan with Dragonstorm", es = "Dispara al Leviathan con Dragonstorm (funciona sin el modo de farmeo)", zh = "打利维坦时用 Dragonstorm 射击（不开刷海龙炮也能用）" },
        ["fast.attack"] = { en = "Fast Attack", es = "Ataque rápido", zh = "快速攻击" },
        ["fast.attack.desc"] = { en = "Fast M1 attacks (not while seated)", es = "Ataques M1 rápidos (no mientras estas sentado)", zh = "近战/剑 M1 快速攻击（坐船时不攻击）" },
        ["follow.player"] = { en = "Follow Player", es = "Seguir jugador", zh = "跟随玩家" },
        ["fps.boost"] = { en = "FPS Boost", es = "Optimizacion de FPS", zh = "FPS 优化" },
        ["fps.boost.desc"] = { en = "Cut water waves, shadows, particles and map materials; also applies to islands streamed in later. Rejoin to restore", es = "Recorta olas, sombras, particulas y materiales del mapa; tambien se aplica a las islas que se cargan despues. Reingresa para restaurar", zh = "削减海浪、阴影、粒子和地图材质，之后新加载的岛屿也会自动套用；关闭后需重进恢复" },
        ["hunt.events"] = { en = "Fight Sea Events While Hunting", es = "Atacar eventos mientras busca", zh = "寻找利维坦时攻击海上事件" },
        ["hunt.events.desc"] = { en = "Fight sea events during hunt", es = "Ataca eventos marinos mientras busca al Leviathan", zh = "寻找利维坦途中打海上事件" },
        ["hunt.select.events"] = { en = "Select Sea Events To Fight", es = "Eventos que debe atacar", zh = "选择攻击的海上事件" },
        ["hunt.select.events.desc"] = { en = "Only fight selected events, skip others (empty = all)", es = "Solo ataca los eventos marcados; el resto los ignora (vacio = todos)", zh = "只攻击选择的事件，未选择的不攻击继续开船（不选=全部）" },
        ["info.ui"] = { en = "Info Display UI", es = "Panel de información", zh = "信息显示 UI" },
        ["info.ui.desc"] = { en = "Show live info overlay at top", es = "Muestra un panel con información en vivo en pantalla", zh = "开启后屏幕顶部生成实时信息浮层" },
        ["language"] = { en = "Language", es = "Idioma", zh = "语言" },
        ["language.desc"] = { en = "Interface language, applied instantly", es = "Idioma de la interfaz, se aplica al instante", zh = "界面语言，立即生效" },
        ["menu.keybind"] = { en = "Menu Keybind", es = "Tecla del menu", zh = "菜单快捷键" },
        ["mode.captain"] = { en = "Captain", es = "Capitán", zh = "开船" },
        ["mode.follower"] = { en = "Follower", es = "Seguidor", zh = "跟随" },
        ["mode.select"] = { en = "Mode Select", es = "Selección de modo", zh = "模式选择" },
        ["notify.lang.changed"] = { en = "Language changed", es = "Idioma cambiado", zh = "语言已切换" },
        ["notify.locked.hunt"] = { en = "In Follower mode the captain handles the hunt settings.", es = "En modo seguidor los ajustes de caza los lleva el Capitán.", zh = "船员模式下，狩猎设置由船长负责。" },
        ["notify.locked.player"] = { en = "In Captain mode you do not pick who to follow. Switch to Follower.", es = "En modo Capitán no se elige a quién seguir. Cambia a Seguidor.", zh = "船长模式下不能选择跟随对象，请切换到船员模式。" },
        ["notify.locked.solo"] = { en = "Solo sea farming controls this switch. Turn solo farming off first.", es = "El modo en solitario controla este interruptor. Apaga antes el farmeo en solitario.", zh = "单人刷海模式控制此开关，请先关闭单人刷海。" },
        ["notify.locked.title"] = { en = "Option locked", es = "Opción bloqueada", zh = "选项已锁定" },
        ["notify.mode.captain"] = { en = "Captain mode: the player list is locked.", es = "Modo Capitán: la lista de jugadores queda bloqueada.", zh = "船长模式：玩家列表已锁定。" },
        ["notify.mode.follower"] = { en = "Follower mode: pick who to follow. The captain handles the hunt settings.", es = "Modo seguidor: elige a quién seguir. Los ajustes de caza los lleva el Capitán.", zh = "船员模式：选择要跟随的玩家，狩猎设置由船长负责。" },
        ["notify.players.refreshed"] = { en = "Player list updated.", es = "Lista de jugadores actualizada.", zh = "玩家列表已更新。" },
        ["notify.ready"] = { en = "Auto Leviathan ready", es = "Leviathan automático listo", zh = "全自动利维坦已就绪" },
        ["notify.title"] = { en = "RJR Hub Notify", es = "RJR Hub | Aviso", zh = "RJR Hub 通知" },
        ["notstarted"] = { en = "Off", es = "Desactivado", zh = "未开启" },
        ["player.tween.speed"] = { en = "Player Tween Speed", es = "Velocidad de desplazamiento", zh = "玩家 Tween 速度" },
        ["player.tween.speed.desc"] = { en = "Player travel speed on foot to boats and sea-event targets (50–500). Applies to teleports and the combat hover", es = "Velocidad a pie al ir al barco y a los eventos marinos (50-500). Afecta a los teletransportes y a la suspensión en combate", zh = "步行前往船和海上事件目标的移动速度（50–500），作用于传送与战斗悬浮" },
        ["refresh.btn"] = { en = "Refresh Player List", es = "Actualizar lista de jugadores", zh = "刷新玩家列表" },
        ["remove.fog"] = { en = "Remove Fog", es = "Quitar la niebla", zh = "移除雾" },
        ["remove.fog.desc"] = { en = "Removes the fog layer (LightingLayers)", es = "Elimina la capa de niebla (LightingLayers) para ver mejor", zh = "删除雾层 LightingLayers，视野清晰" },
        ["reset.data"] = { en = "Reset Data", es = "Reiniciar datos", zh = "重置数据" },
        ["respawn.rebuy"] = { en = "Respawn Rebuy", es = "Recomprar al reaparecer", zh = "重生买船" },
        ["respawn.rebuy.desc"] = { en = "Respawns at Tiki when the boat is destroyed or missing (follower included). The follower also dies with the captain so both rebuy together. Never respawns while the Leviathan, its gate or its heart are present", es = "Reaparece en Tiki si el barco se destruye o desaparece (tambien el compañero). El compañero tambien muere con el capitan para recomprar los dos juntos. Nunca reaparece con el Leviathan, su puerta o su corazon presentes", zh = "船被毁或消失时重生回Tiki买船（队员同样生效）；队员会随队长一起死亡，好一起买船；利维坦/利维坦之门/心脏出现时绝不重生" },
        ["sec.combat"] = { en = "Combat Settings", es = "Ajustes de combate", zh = "战斗设置" },
        ["sec.haki"] = { en = "Haki & Race", es = "Haki y raza", zh = "霸气与种族" },
        ["sec.hunt"] = { en = "Hunt Settings", es = "Ajustes de caza", zh = "狩猎设置" },
        ["sec.main"] = { en = "Main", es = "Principal", zh = "主功能" },
        ["sec.mode"] = { en = "Mode", es = "Modo", zh = "模式" },
        ["sec.performance"] = { en = "Performance & Effects", es = "Rendimiento y efectos", zh = "性能与特效" },
        ["sec.team"] = { en = "Teammates", es = "Compañeros", zh = "队友" },
        ["sec.travel"] = { en = "Travel Settings", es = "Ajustes de navegación", zh = "航行设置" },
        ["sel.weapon"] = { en = "Select Weapon", es = "Seleccionar arma", zh = "选择武器" },
        ["silent.aim"] = { en = "Silent aim (skills)", es = "Apuntado asistido (silent aim)", zh = "静默瞄准（技能）" },
        ["silent.aim.desc"] = { en = "Skills are aimed at the current mob or Leviathan, ignoring camera and mouse", es = "Las habilidades apuntan al mob o al Leviathan, ignorando camara y raton", zh = "技能自动瞄准当前怪物或利维坦，忽略视角和鼠标" },
        ["skill.fruit"] = { en = "Skill Keys Fruit", es = "Teclas de habilidad (fruta)", zh = "技能按键 Fruit" },
        ["skill.gun"] = { en = "Skill Keys Gun", es = "Teclas de habilidad (pistola)", zh = "技能按键 Gun" },
        ["skill.melee"] = { en = "Skill Keys Melee", es = "Teclas de habilidad (puños)", zh = "技能按键 Melee" },
        ["skill.sword"] = { en = "Skill Keys Sword", es = "Teclas de habilidad (espada)", zh = "技能按键 Sword" },
        ["solo.seafarm"] = { en = "Solo Sea Event Farming", es = "Farmeo marino en solitario", zh = "单人刷海上事件" },
        ["solo.seafarm.desc"] = { en = "Only attack sea events selected in the dropdown", es = "Ataca solo los eventos elegidos en la lista", zh = "攻击下拉框选中的海上事件" },
        ["status.current"] = { en = "Current Status", es = "Estado actual", zh = "当前状态" },
        ["status.detail"] = { en = "Details", es = "Detalles", zh = "详情" },
        ["status.off"] = { en = "Disabled", es = "Desactivado", zh = "已关闭" },
        ["status.on"] = { en = "Enabled", es = "Activado", zh = "已开启" },
        ["status.prefix.follow"] = { en = "Following:", es = "Siguiendo:", zh = "跟随:" },
        ["status.stopped"] = { en = "Stopped", es = "Detenido", zh = "已停止" },
        ["status.target"] = { en = "Target Status", es = "Estado del objetivo", zh = "目标状态" },
        ["stop.btn"] = { en = "Stop", es = "Detener", zh = "停止" },
        ["tab.announcement"] = { en = "Announcement", es = "Anuncio", zh = "公告" },
        ["tab.combat"] = { en = "Combat", es = "Combate", zh = "战斗" },
        ["tab.config"] = { en = "Config", es = "Configuración", zh = "配置" },
        ["tab.craft"] = { en = "Misc", es = "Extras", zh = "其他" },
        ["tab.main"] = { en = "Leviathan", es = "Leviathan", zh = "利维坦" },
        ["tab.perf"] = { en = "Performance", es = "Rendimiento", zh = "性能" },
        ["tab.status"] = { en = "Leviathan", es = "Leviathan", zh = "利维坦" },
        ["tab.webhook"] = { en = "Webhook", es = "Webhook", zh = "Webhook" },
        ["target.gate"] = { en = "Gate Spawned (Ready)", es = "Puerta aparecida (lista)", zh = "门已出现 待开启" },
        ["target.heart"] = { en = "Heart", es = "Corazón", zh = "心脏" },
        ["target.hooked"] = { en = "Hooked", es = "Enganchado", zh = "已勾中" },
        ["target.hp"] = { en = "HP", es = "Vida", zh = "血量" },
        ["target.not.spawned"] = { en = "Not Spawned", es = "No apareció", zh = "未出现" },
        ["target.spawned"] = { en = "Spawned", es = "Aparecido", zh = "已出现" },
        ["ui.bribe"] = { en = "Bribe", es = "Soborno", zh = "贿赂" },
        ["ui.floatingball"] = { en = "Floating Button", es = "Botón flotante", zh = "悬浮球" },
        ["ui.floatingball.desc"] = { en = "Draggable button to open/close this menu (hotkey G always works)", es = "Botón arrastrable para abrir/cerrar el menú (la tecla G siempre funciona)", zh = "可拖动的悬浮球，点击开关菜单（热键 G 始终可用）" },
        ["ui.details"] = { en = "Details", es = "Detalles", zh = "详情" },
        ["ui.teammates"] = { en = "Teammates", es = "Compañeros", zh = "队友" },
        ["webhook.auto"] = { en = "Auto Send Progress", es = "Enviar progreso automáticamente", zh = "自动发送进度" },
        ["webhook.auto.desc"] = { en = "Send current status to webhook every 60s", es = "Envia el estado al webhook cada 60 segundos", zh = "每 60 秒发送当前状态到 webhook" },
        ["webhook.interval"] = { en = "Send Interval (s)", es = "Intervalo (segundos)", zh = "发送间隔(秒)" },
        ["webhook.off"] = { en = "Off", es = "Desactivado", zh = "未开启" },
        ["webhook.send.bribe"] = { en = "Send On Cooldown Ready", es = "Enviar cuando el soborno este listo", zh = "CD好时发送" },
        ["webhook.send.bribe.desc"] = { en = "Send once when bribe CD is ready", es = "Envia un aviso cuando termina la espera del soborno", zh = "贿赂CD结束时可发送一次" },
        ["webhook.send.heartgot"] = { en = "Send On Heart Grabbed", es = "Enviar cuando se engancha el corazón", zh = "得到心脏时发送" },
        ["webhook.send.heartspawn"] = { en = "Send On Heart Spawn", es = "Enviar cuando aparece el corazón", zh = "心脏出现时发送" },
        ["webhook.send.leviathan"] = { en = "Send On Leviathan Spawn", es = "Enviar cuando aparece el Leviathan", zh = "利维坦出现时发送" },
        ["webhook.send.now"] = { en = "Send Now", es = "Enviar progreso ahora", zh = "立即发送进度" },
        ["webhook.send.progress"] = { en = "Periodic Sail Progress", es = "Enviar progreso periodicamente", zh = "定时发送航海进度" },
        ["webhook.send.progress.desc"] = { en = "Send status/heart/scale/scroll counts every interval", es = "Envia estado, corazones, escamas y pergaminos cada cierto tiempo", zh = "每设定秒数发送 状态/心脏/鳞片/卷轴 数量" },
        ["webhook.sending"] = { en = "Sending...", es = "Enviando...", zh = "发送中..." },
        ["webhook.sent"] = { en = "Sent: ", es = "Enviado: ", zh = "已发送: " },
        ["webhook.status"] = { en = "Send Status", es = "Enviar estado", zh = "发送状态" },
        ["webhook.url"] = { en = "Webhook URL", es = "Enlace del webhook", zh = "Webhook 链接" },
        ["webhook.url.desc"] = { en = "Discord webhook URL (auto send progress)", es = "URL de Discord donde recibir el progreso", zh = "Discord Webhook 接收链接（自动发送进度）" },
        ["webhook.username"] = { en = "Sender Name", es = "Nombre del remitente", zh = "发送者名称" },
        ["webhook.username.desc"] = { en = "Discord sender display name (default Auto Leviathan)", es = "Nombre que se muestra en Discord (por defecto Auto Leviathan)", zh = "Discord 消息发送者显示名（默认 Auto Leviathan）" },
        ["wh.bribe"] = { en = "Spy Bribe", es = "Soborno al espía", zh = "贿赂间谍" },
        ["wh.crafted"] = { en = "Crafting", es = "Fabricación", zh = "制作" },
        ["wh.field.display"] = { en = "Display Name", es = "Nombre visible", zh = "显示名称" },
        ["wh.field.uid"] = { en = "User ID", es = "ID de usuario", zh = "用户ID" },
        ["wh.field.user"] = { en = "Username", es = "Usuario", zh = "用户名" },
        ["wh.lowplayers"] = { en = "Low players", es = "Pocos jugadores", zh = "人数不足" },
        ["wh.lowplayers.desc"] = { en = "@everyone when server players (incl. you) < 5", es = "Avisa con @everyone cuando hay menos de 5 jugadores (contigo)", zh = "服务器人数(含自己)不足5人时 @everyone 通知" },
        ["wh.lowplayers.msg"] = { en = "Current players: ", es = "Jugadores actuales: ", zh = "当前人数: " },
        ["wh.material"] = { en = "Materials", es = "Materiales", zh = "材料" },
        ["wh.msg.bribe.ready"] = { en = "[Auto Leviathan] Bribe CD ready - progress {n}/5", es = "[Auto Leviathan] Soborno disponible - progreso {n}/5", zh = "[Auto Leviathan] 贿赂CD已好 进度 {n}/5" },
        ["wh.msg.heartgot"] = { en = "[Auto Leviathan] Heart hooked!", es = "[Auto Leviathan] Corazón enganchado", zh = "[Auto Leviathan] 已勾到心脏!" },
        ["wh.msg.heartspawn"] = { en = "[Auto Leviathan] Heart spawned!", es = "[Auto Leviathan] El corazón apareció", zh = "[Auto Leviathan] 心脏出现!" },
        ["wh.msg.leviathan"] = { en = "[Auto Leviathan] Leviathan spawned!", es = "[Auto Leviathan] El Leviathan apareció", zh = "[Auto Leviathan] 利维坦出现!" },
        ["wh.none"] = { en = "None", es = "Ninguno", zh = "无" },
        ["wh.scroll"] = { en = "Scrolls", es = "Pergaminos", zh = "卷轴" },
        ["wh.sendfailed"] = { en = "Send Failed", es = "Error al enviar", zh = "发送失败" },
        ["wh.title.bribe"] = { en = "Bribe CD Ready", es = "Soborno disponible", zh = "贿赂CD已好" },
        ["wh.title.heartgot"] = { en = "Heart Grabbed", es = "Corazón enganchado", zh = "已勾到心脏" },
        ["wh.title.heartspawn"] = { en = "Heart Spawned", es = "Corazón aparecido", zh = "心脏出现" },
        ["wh.title.leviathan"] = { en = "Leviathan Spawned", es = "Leviathan apareció", zh = "利维坦出现" },
        ["wh.title.lowplayers"] = { en = "Low Players", es = "Pocos jugadores", zh = "人数不足" },
        ["wh.title.manual"] = { en = "Manual Send", es = "Envio manual", zh = "手动发送" },
        ["wh.title.progress"] = { en = "Sail Progress", es = "Progreso de navegación", zh = "航海进度" },
    }
    local function T(key)
        local entry = LangTable[key]
        if not entry then
            return key
        end
        return entry[LanguageCode()] or entry.en or entry.es or entry.zh or key
    end
    local function ModeDisplay()
        return (_G.Mode == "Capitán") and T("mode.captain") or T("mode.follower")
    end
    _G.Language = NormalizeLanguage(_G.Language)
        or (getgenv and NormalizeLanguage(getgenv().language))
        or "English"
    _G.RJR_LanguageLabels = LANGUAGE_LABELS
    _G.RJR_NormalizeLanguage = NormalizeLanguage
    _G.RJR_LanguageCode = LanguageCode
    return T, ModeDisplay
end)()
_G.Mode = _G.Mode or "Capitán"
_G.FollowTarget = _G.FollowTarget or ""
_G.AutoLeviathanFull = false
_G.StopTween = false
if _G.ShowInfoUI == nil then _G.ShowInfoUI = false end
if _G.SilentAim == nil then _G.SilentAim = true end
if _G.SelectWeapon == nil then _G.SelectWeapon = "Sword" end
if _G.SkillMelee == nil then _G.SkillMelee = {"Z", "X", "C"} end
if _G.SkillSword == nil then _G.SkillSword = {"Z", "X"} end
if _G.SkillFruit == nil then _G.SkillFruit = {"X"} end
if _G.SkillGun == nil then _G.SkillGun = {"Z", "X"} end
if _G.FastAttack_Mode == nil then _G.FastAttack_Mode = "2" end
if _G.AutoBuso == nil then _G.AutoBuso = true end
if _G.AutoKen == nil then _G.AutoKen = false end
if _G.FastAttack == nil then _G.FastAttack = false end
if _G.DragonGunFarm == nil then _G.DragonGunFarm = false end
if _G.DragonGunLeviathan == nil then _G.DragonGunLeviathan = false end
if _G.RemoveFog == nil then _G.RemoveFog = false end
if _G.AntiDracoAura == nil then _G.AntiDracoAura = false end
if _G.AutoFastMode == nil then _G.AutoFastMode = false end
if _G.FPSBoost == nil then _G.FPSBoost = false end
if _G.AutoV3 == nil then _G.AutoV3 = false end
if _G.AutoV4 == nil then _G.AutoV4 = false end
if _G.BoatLockY == nil then _G.BoatLockY = 150 end
if _G.BoatHeight == nil then _G.BoatHeight = _G.BoatLockY end
if _G.BoatSpeed == nil then _G.BoatSpeed = 250 end
if _G.PlayerTweenSpeed == nil then _G.PlayerTweenSpeed = 275 end
if _G.AutoCraftScrolls == nil then _G.AutoCraftScrolls = false end
if _G.CraftQuality == nil then _G.CraftQuality = "None" end
if _G.AutoRandomFruit == nil then _G.AutoRandomFruit = false end
if _G.AutoStoreFruits == nil then _G.AutoStoreFruits = false end
if _G.HuntFightEvents == nil then _G.HuntFightEvents = false end
if _G.SoloSeaFarm == nil then _G.SoloSeaFarm = false end
if _G.RespawnRebuy == nil then _G.RespawnRebuy = false end
if _G.CruiseReturn == nil then _G.CruiseReturn = true end
if _G.HuntSelectEvents == nil then _G.HuntSelectEvents = {} end
if _G.WebhookURL == nil then _G.WebhookURL = "" end
if _G.WebhookUsername == nil then _G.WebhookUsername = "Auto Leviathan" end
if _G.AutoWebhook == nil then _G.AutoWebhook = false end
if _G.WebhookInterval == nil then _G.WebhookInterval = 60 end
if _G.WebhookSendProgress == nil then _G.WebhookSendProgress = false end
if _G.WebhookSendBribeReady == nil then _G.WebhookSendBribeReady = false end
if _G.WebhookSendLeviathan == nil then _G.WebhookSendLeviathan = false end
if _G.WebhookSendHeartSpawn == nil then _G.WebhookSendHeartSpawn = false end
if _G.WebhookSendHeartGot == nil then _G.WebhookSendHeartGot = false end
if _G.WebhookSendLowPlayers == nil then _G.WebhookSendLowPlayers = false end
local Character = LocalPlayer.Character
local HD = Character and Character:FindFirstChild("Humanoid")
local HRP = Character and Character:FindFirstChild("HumanoidRootPart")
local CurrentTween = nil
local LastAttackTime = 0
local SkillCoolDown = false
local LastAllWeapon = 0
local AttackSeedCache, AttackSeedAt = nil, 0
local AttackNet, AttackRegisterAttack, AttackRegisterHit, AttackSeedRemote = nil, nil, nil, nil
local AttackObfuscatedRemote, AttackObfuscatedId = nil, nil
local FightTarget = nil
local AttackModel = nil
local AttackStandFn = nil
local StatusText = T("notstarted")
local StatusPrefix = ""
local TranslateStatus, SetStatus
TranslateStatus, SetStatus = (function(LanguageCode)
    local StatusStatic = {
        ["Barco viejo inservible: espero el reinicio para recomprar"] = { en = "Old boat unusable: waiting for the reset to rebuy", zh = "旧船不可用 等待重生后重买" },
        ["No pude bajarme antes de comprar: voy igual al vendedor"] = { en = "Failed to unseat before buying, still heading to dealer", zh = "买船前下船失败 仍尝试前往卖船点" },
        ["No llegué al vendedor de barcos: reintentando"] = { en = "Did not reach boat dealer, retrying", zh = "未到达卖船点 稍后重试买船" },
        ["El barco desapareció: vuelo a comprar otro"] = { en = "Boat gone, flying to buy new boat", zh = "船已消失 平滑飞行去买船" },
        ["Barco nuevo comprado: esperando a los compañeros"] = { en = "New boat bought, waiting for teammates", zh = "新船已买 等待队友上船" },
        ["Barco hundido (Y<0): lo abandono y compro otro"] = { en = "Boat Y below 0, abandoning and rebuying", zh = "船Y轴低于0 放弃当前船 重新买船" },
        ["Crucero atascado: bajo y vuelvo a subir para reiniciar"] = { en = "Cruise stalled, reseating and restarting", zh = "巡航卡船 下船重上重开驱动" },
        ["El capitán volvió al barco: dejo de pelear y vuelvo"] = { en = "Captain back on boat, returning to boat", zh = "队长已回船 停止战斗 返回船上" },
        ["Farmeo marino: comprobando salir del asiento"] = { en = "Farming event, repeatedly checking seat", zh = "刷海上事件 反复检查脱离座位" },
        ["Pelea a pie: comprobando salir del asiento"] = { en = "Unseating to fight, checking repeatedly", zh = "下船战斗 反复检查脱离座位" },
        ["No consigo bajarme: salgo de este combate"] = { en = "Failed to unseat, exiting this combat", zh = "下船反复失败 退出本轮战斗" },
        ["Leviathan no encontrado por ahora: sigo esperando"] = { en = "Leviathan not found yet, still waiting", zh = "利维坦暂时未找到 继续等待出现" },
        ["Vida recuperada: sigo atacando"] = { en = "HP restored, resuming attack", zh = "血量已恢复 继续攻击" },
        ["Sigo sentado antes de atacar: me bajo a la fuerza"] = { en = "Still seated, forcing unseat", zh = "攻击前发现仍坐着 强制下船" },
        ["Enganche fallido: no hay corazón"] = { en = "Hook failed, no heart", zh = "勾心脏失败 心脏不存在" },
        ["Enganche fallido: el barco no tiene asiento de arpón"] = { en = "Hook failed, no harpoon seat on boat", zh = "勾心脏失败 船上没有鱼叉座位" },
        ["Enganche: no estoy en el timón, salto esta ronda"] = { en = "Hook: not on helm, skipping round", zh = "勾心脏 调整前不在驾驶座 跳过本轮" },
        ["Enganche: me caí del asiento, dejo de girar"] = { en = "Hook: fell off seat, stopping aim", zh = "勾心脏 调整中掉座 停止调整" },
        ["Enganche fallido: no pude bajarme, salto la ronda"] = { en = "Hook failed, unseat failed, skipping round", zh = "勾心脏失败 下船失败 跳过本轮" },
        ["Enganche fallido: no pude subir al asiento del arpón"] = { en = "Hook failed, could not board harpoon seat", zh = "勾心脏失败 上鱼叉座位失败" },
        ["Enganche: el corazón desapareció"] = { en = "Hook: heart gone", zh = "勾心脏 心脏已消失" },
        ["Enganche fallido: bajo del arpón para reintentar"] = { en = "Hook missed, unseating for next round", zh = "勾心脏 未勾中 下鱼叉座准备下一轮" },
        ["No pude bajar del arpón: intento la siguiente ronda"] = { en = "Hook: unseat failed, retrying next round", zh = "勾心脏 下鱼叉座失败 仍尝试下一轮" },
        ["¡Corazón enganchado!"] = { en = "Heart hooked", zh = "勾心脏成功" },
        ["Fallo: el corazón no quedó enganchado"] = { en = "Hook failed, heart not hooked", zh = "勾心脏失败 心脏未勾中" },
        ["En la puerta del Leviathan: esperando a que aparezca"] = { en = "At the Leviathan gate, waiting for it to appear", zh = "已到利维坦之门 等待利维坦出现" },
        ["Leviathan apareció: empiezo el combate"] = { en = "Leviathan spawned, starting combat", zh = "利维坦已出现 开始战斗" },
        ["Menos de 200 en 30 s: bajo y vuelvo a subir para reiniciar"] = { en = "Moved <200 in 30s, reseating and restarting", zh = "30秒内移动不足200 下船重上重开驱动" },
        ["Atascado y no pude bajarme: sigo esperando"] = { en = "Stuck and unseat failed, waiting", zh = "卡船且下船失败 继续等待" },
        ["Volviendo a Tiki"] = { en = "Returning to Tiki", zh = "回Tiki 返航中" },
        ["Volviendo a Tiki: el corazón desapareció, cancelo"] = { en = "Returning to Tiki, heart gone, aborting", zh = "回Tiki 心脏已消失 中断航程" },
        ["El corazón desapareció: dejo de volver a Tiki"] = { en = "Heart gone, stopping return to Tiki", zh = "心脏已消失 立即停止返回Tiki" },
        ["Debajo del corazón: espero 1.5 s"] = { en = "Under heart, waiting 1.5s", zh = "回Tiki 已到心脏正下方 等待1.5秒" },
        ["De vuelta en Tiki: espero a que el corazón desaparezca"] = { en = "Back at Tiki, waiting for heart", zh = "已回到 Tiki 等待心脏消失" },
        ["Se agotó la espera de compañeros"] = { en = "Timed out waiting for teammates", zh = "等待队友超时 不再等待" },
        ["Esperando compañeros: el capitán sube al timón primero"] = { en = "Waiting for team, captain helms first", zh = "等待队友 队长先上驾驶座" },
        ["El barco desapareció: vuelvo a comprarlo"] = { en = "Boat gone, rebuying", zh = "等待队友 船已消失 返回重新买船" },
        ["El barco nuevo no tiene timón: vuelvo a comprar"] = { en = "New boat has no helm, rebuying", zh = "等待队友 新船无驾驶座 返回重买" },
        ["El barco desapareció mientras esperaba: vuelvo a comprar"] = { en = "Boat gone while waiting, rebuying", zh = "等待队友期间船已消失 返回重新买船" },
        ["El compañero más cercano está a más de 10000: vuelvo a comprar barco"] = { en = "Nearest teammate >10000, rebuying boat", zh = "最近的队员超过10000 回去重新买船" },
        ["Compañeros demasiado lejos: vuelvo al muelle a comprar"] = { en = "Teammate too far, returning to dock to rebuy", zh = "队友距离过远 回码头重新买船" },
        ["No pude bajarme: sigo intentando pelear"] = { en = "Unseat failed, retrying combat", zh = "下船失败 继续尝试战斗" },
        ["No pude subir al timón: vuelvo al bucle principal"] = { en = "Failed to helm, back to main loop", zh = "上驾驶座失败 返回主循环" },
        ["Farmeo en solitario: no espero compañeros"] = { en = "Solo farm: skipping teammate wait", zh = "单人刷海 跳过等待队友" },
        ["Esperando a 4 compañeros a bordo"] = { en = "Waiting for 4 teammates", zh = "等待4名队友上船" },
        ["4 compañeros a bordo: navego en 0.5 s"] = { en = "4 teammates aboard, sailing in 0.5s", zh = "4名队友已上船 等待0.5秒后开始航海" },
        ["4 compañeros a bordo: listos para farmear"] = { en = "4 teammates aboard, ready to farm", zh = "4名队友已上船 准备开船刷海" },
        ["Leviathan apareció: dejo el farmeo y voy a cazarlo"] = { en = "Leviathan spawned, switching to hunt", zh = "利维坦出现 停止刷海 转猎杀" },
        ["Farmeo marino: peleando a pie"] = { en = "Farming event, fighting", zh = "刷海上事件 下船战斗中" },
        ["Corazón enganchado: subo al barco en 5 s"] = { en = "Heart hooked, boarding in 5s", zh = "心脏已勾中 等待5秒后上船" },
        ["Corazón enganchado: subo al timón"] = { en = "Heart hooked, boarding helm", zh = "心脏已勾中 上驾驶座" },
        ["En el timón: vuelvo a Tiki en 10 s"] = { en = "On helm, returning to Tiki in 10s", zh = "已上驾驶座 等待10秒后返回Tiki" },
        ["El corazón desapareció: voy al muelle a comprar barco"] = { en = "Heart gone, going to buy new boat", zh = "心脏已消失 前往码头买新船" },
        ["El barco desapareció: compro uno nuevo sin esperar el corazón"] = { en = "Boat gone, buying new boat now", zh = "船已消失 不等心脏 直接买新船" },
        ["El corazón desapareció y no pude bajarme: voy igual a comprar"] = { en = "Heart gone, unseat failed, heading to buy", zh = "心脏已消失 下船失败 仍尝试前往买船" },
        ["El barco desapareció durante la caza: vuelvo al bucle principal"] = { en = "Boat gone during hunt, back to main loop", zh = "猎杀中船已消失 停止猎杀 回主循环" },
        ["Me caí del asiento: vuelvo al timón"] = { en = "Fell off seat, re-helming", zh = "猎杀中掉座 尝试重新上驾驶座" },
        ["No pude volver al barco: vuelvo al bucle principal"] = { en = "Re-board failed, back to main loop", zh = "猎杀中重新上船失败 回主循环" },
        ["La puerta del Leviathan apareció: detengo el barco"] = { en = "Leviathan gate spawned, stopping boat", zh = "利维坦之门已出现 停船" },
        ["El barco desapareció mientras esperaba: dejo la caza"] = { en = "Boat gone while waiting, stopping hunt", zh = "等待队友期间船已消失 停止猎杀" },
        ["Buscando al Leviathan: sigo navegando"] = { en = "Hunting Leviathan, continue sailing", zh = "寻找利维坦 继续航行" },
        ["La caza terminó con error: reinicio"] = { en = "Hunt error, restarting", zh = "猎杀异常退出 重新开始" },
        ["No pude bajarme: reintento"] = { en = "Unseat failed, retrying", zh = "下船失败 回主循环重试" },
        ["Leviathan no derrotado: reinicio"] = { en = "Leviathan not defeated, restarting", zh = "利维坦未击败 重新开始" },
        ["Leviathan derrotado"] = { en = "Leviathan defeated", zh = "利维坦已击败" },
        ["El corazón apareció: engancho en 20 s"] = { en = "Heart spawned, hooking in 20s", zh = "心脏已出现 等待20秒后再勾" },
        ["Corazón detectado: continúo con el enganche"] = { en = "Heart detected, continuing hook", zh = "检测到心脏 继续勾心脏流程" },
        ["Esperando el estado del soborno (no disponible)"] = { en = "Could not get bribe status", zh = "等待贿赂状态 无法获取" },
        ["Leviathan detectado: voy a cazarlo"] = { en = "Leviathan detected, hunting", zh = "检测到利维坦 直接猎杀" },
        ["Soborno completado: empiezo la caza del Leviathan"] = { en = "Bribe done, hunting Leviathan", zh = "贿赂完毕 开始猎杀利维坦" },
        ["Soborno incompleto: farmeo eventos mientras espero"] = { en = "Bribe incomplete, farming events", zh = "贿赂未完成 刷海上事件等CD" },
        ["Farmeo en solitario: empiezo a patrullar"] = { en = "Solo farm: starting patrol", zh = "单人刷海 开始巡海" },
        ["Siguiendo: el barco está lejos, me acerco volando"] = { en = "Following, boat far, flying closer", zh = "跟随 船离得远 平滑飞行靠近" },
        ["Siguiendo: no hay asientos libres (¿4/4?)"] = { en = "Following, no free seat (4/4?)", zh = "跟随 没有空座位 (4/4已满?)" },
        ["El corazón desapareció: subo al barco a seguir"] = { en = "Heart gone, boarding to follow", zh = "心脏已消失 上船跟随" },
        ["Corazón enganchado: subo al cañón"] = { en = "Heart hooked, boarding cannon", zh = "心脏已勾中 上船坐炮台" },
        ["En espera en el barco (corazón enganchado)"] = { en = "On standby on boat (heart hooked)", zh = "在船上待命 (心脏已勾中)" },
        ["Corazón enganchado: sigo al capitán"] = { en = "Heart hooked, following captain", zh = "心脏已勾中 跟随队长" },
        ["Leviathan apareció: cancelo el viaje a la puerta"] = { en = "Leviathan spawned, canceling gate teleport", zh = "利维坦出现 取消门传送" },
        ["Leviathan apareció y no pude bajarme: reintentando"] = { en = "Leviathan spawned, unseat failed, retrying", zh = "利维坦出现 下船失败 重试中" },
        ["Leviathan apareció: me bajo a pelear"] = { en = "Leviathan spawned, unseating to fight", zh = "利维坦出现 下船战斗" },
        ["El capitán bajó y yo no puedo: reintentando"] = { en = "Captain off, unseat failed, retrying", zh = "队长已下船 下船失败 重试中" },
        ["El capitán bajó: bajo también"] = { en = "Captain off, following off", zh = "队长已下船 跟随下船" },
        ["Barco del capitán perdido: peleo mientras compra otro"] = { en = "Captain boat gone, fighting while he rebuys", zh = "队长船已消失 继续战斗 等队长买新船" },
        ["Leviathan apareció: fuerzo salir del viaje a la puerta"] = { en = "Leviathan spawned, exiting gate teleport", zh = "利维坦出现 强制退出门传送" },
        ["La puerta del Leviathan apareció: me teletransporto"] = { en = "Leviathan gate spawned, teleporting to gate", zh = "利维坦之门出现 传送到门位置" },
        ["Me teletransporto al corazón"] = { en = "Teleporting to heart", zh = "传送到心脏位置" },
        ["Siguiendo al capitán (esperando el corazón)"] = { en = "Following captain (waiting heart)", zh = "跟随队长 (等心脏出现)" },
        ["El capitán está a pie, sin objetivo: en espera"] = { en = "Captain off, no target, standby", zh = "队长下船中 无目标 待命" },
        ["Barco hundido (Y<0)"] = { en = "Boat Y below 0", zh = "船Y轴低于0" },
        ["Barco destruido (vida 0)"] = { en = "Boat destroyed (0 HP)", zh = "船血量为0" },
        ["Barco del capitán inservible"] = { en = "Captain's boat unusable", zh = "队长船不可用" },
        ["Barco del capitán desaparecido"] = { en = "Captain's boat gone", zh = "队长船已消失" },
        ["Capitán muerto"] = { en = "Captain died", zh = "队长死亡" },
        ["Leviathan, puerta o corazón presentes: no reinicio"] = { en = "Leviathan, gate or heart present: not resetting", zh = "利维坦/门/心脏已出现 不重生" },
        ["Sigo bloqueado, pero hay Leviathan/puerta/corazón: no reinicio"] = { en = "Still stuck but Leviathan/gate/heart present: not resetting", zh = "仍然卡住 但利维坦/门/心脏已出现 不重生" },
        ["Asiento fantasma: lo suelto y vuelvo a subir"] = { en = "Phantom seat: releasing it and boarding again", zh = "坐下状态未生效 松开座位 重新上船" },
        ["Sigo bloqueado: reinicio el personaje en Tiki"] = { en = "Still stuck, resetting the character at Tiki", zh = "仍未恢复 重置角色回Tiki" },
        ["Corazón presente y sin barco: voy a comprar uno"] = { en = "Heart present but no boat: going to buy one", zh = "心脏已出现但没有船 去买船" },
    }
    local StatusPatterns = {
        { es = "Personaje bloqueado en el sitio ({1}): lo libero", en = "Character stuck in place ({1}): freeing it", zh = "人物卡在原地 ({1}) 正在解卡", nested = false },
        { es = "Siguiendo: el barco del capitán está a más de {1} — no lo persigo", en = "Following: captain's boat is over {1} away - not chasing it", zh = "跟随 队长船超出{1} 不追", nested = false },
        { es = "Volviendo a Tiki: corazón a {1} — voy justo debajo del corazón", en = "Returning, heart {1} away, moving under heart", zh = "回Tiki 心脏离船 {1} 开向心脏正下方", nested = false },
        { es = "Enganche: espero el resultado (disparo {1}, esperando {2} s)", en = "Hook: waiting after shot ({1} fired, {2}s)", zh = "勾心脏 发射后等待判断 (第{1}发 已等 {2} 秒)", nested = false },
        { es = "Abriendo la puerta del Leviathan (intento {1}, cada 10 s)", en = "Opening Leviathan gate (attempt {1}, every 10s)", zh = "开启利维坦之门 第{1}次尝试 (每10秒一次)", nested = false },
        { es = "Esperando el corazón: me teletransporto (llevo {1} s)", en = "Waiting on heart, TPing to its position ({1}s)", zh = "等待心脏 传送至心脏位置 (已等 {1} 秒)", nested = false },
        { es = "Compañero lejos, recompra en espera: aguardo ({1} s)", en = "Teammate far, rebuy on cooldown, waiting ({1}s)", zh = "最近队员过远 重买冷却中 等待队友 ({1} 秒)", nested = false },
        { es = "Esperando a que el corazón desaparezca (llevo {1} s)", en = "Waiting for heart to vanish ({1}s)", zh = "等待心脏消失 (已等 {1} 秒)", nested = false },
        { es = "[Auto Leviathan] Soborno disponible - progreso {1}/5", en = "[Auto Leviathan] Bribe ready - progress {1}/5", zh = "[Auto Leviathan] 贿赂CD已好 进度 {1}/5", nested = false },
        { es = "El corazón apareció: engancho en 25 s (llevo {1} s)", en = "Heart spawned, hooking in 25s ({1}s)", zh = "心脏已出现 等待25秒后勾心脏 (已等 {1} 秒)", nested = false },
        { es = "Enganche: navego a X+300 del corazón (intento {1})", en = "Hook: sailing to heart X+300 (attempt {1})", zh = "勾心脏 开船前往心脏X+300位置 (第{1}次尝试)", nested = false },
        { es = "Enganche: navegando a X+300 del corazón (dist {1})", en = "Hook: sailing to heart X+300 (dist {1})", zh = "勾心脏 开船前往心脏X+300 (距离 {1})", nested = false },
        { es = "Volviendo a Tiki: corazón a {1} del barco, cancelo", en = "Returning, heart {1} from boat, aborting", zh = "回Tiki 心脏离船 {1} 中断航程", nested = false },
        { es = "Siguiendo: pruebo el asiento {1} (cambio cada 1 s)", en = "Following, trying seat {1} (rotating every 1s)", zh = "跟随 尝试上船 {1} 座位 (每1秒换下一个)", nested = false },
        { es = "Enganche: apunto la proa al corazón (intento {1})", en = "Hook: aiming bow at heart (attempt {1})", zh = "勾心脏 调整船头对准心脏 (第{1}次尝试)", nested = false },
        { es = "Enganche: bajo al asiento del arpón (intento {1})", en = "Hook: unseating to harpoon seat (attempt {1})", zh = "勾心脏 下船上鱼叉座 (第{1}次尝试)", nested = false },
        { es = "Esperando a que aparezca el corazón (llevo {1} s)", en = "Waiting for heart ({1}s)", zh = "等待心脏出现 (已等 {1} 秒)", nested = false },
        { es = "Buscando al Leviathan: navegando (llevo {1} s)", en = "Hunting Leviathan, sailing ({1}s)", zh = "寻找利维坦 开船航行中 (已航行 {1} 秒)", nested = false },
        { es = "Barco a más de {1}, lo abandono y compro otro", en = "Boat is over {1} away, abandoning it and buying another", zh = "船超出{1} 放弃旧船 重新买船", nested = false },
        { es = "Enganche: disparo el arpón nº {1} (ángulo {2}°)", en = "Hook: firing harpoon {1} (angle {2}°)", zh = "勾心脏 发射鱼叉第{1}次 (角度 {2}°)", nested = false },
        { es = "En espera en el barco (capitán {1} al timón)", en = "On standby (captain {1} at helm)", zh = "在船上待命 (队长 {1} 在驾驶)", nested = false },
        { es = "{1}: reiniciando en Tiki para comprar barco", en = "{1}: resetting to Tiki to buy a boat", zh = "{1} 重置回Tiki买船", nested = true },
        { es = "{1}: esperando a terminar el evento marino", en = "{1}: waiting to finish the sea event", zh = "{1} 等待打完海上事件", nested = true },
        { es = "Volviendo a Tiki (dist {1}, navegando {2} s)", en = "Returning to Tiki (dist {1}, {2}s sailed)", zh = "回Tiki 自动巡航中 (距离 {1} 已航 {2} 秒)", nested = false },
        { es = "Soborno incompleto ({1}/5): soborno ahora", en = "Bribe incomplete ({1}/5), bribing now", zh = "间谍贿赂未完成 ({1}/5) 立即贿赂", nested = false },
        { es = "Farmeo marino: patrullando (llevo {1} s)", en = "Farming event, cruising ({1}s)", zh = "刷海上事件 开船巡海中 (已刷 {1} 秒)", nested = false },
        { es = "El Leviathan apareció: ataco en {1} s", en = "Leviathan spawned, attacking in {1}s", zh = "利维坦出现 等待{1}秒后攻击", nested = false },
        { es = "Enganche: subo al timón (intento {1})", en = "Hook: boarding helm (attempt {1})", zh = "勾心脏 上驾驶座 (第{1}次尝试)", nested = false },
        { es = "Esperando compañeros a bordo ({1}/4)", en = "Waiting for teammates ({1}/4)", zh = "等待队友上船 ({1}/4)", nested = false },
        { es = "Sobornando al espía (intento {1}/4)", en = "Bribing spy ({1}/4)", zh = "贿赂间谍 第{1}次", nested = false },
        { es = "Atacando al Leviathan: {1} - vida {2}", en = "Attacking the Leviathan: {1} - HP {2}", zh = "攻击利维坦: {1} 血量 {2}", nested = false },
        { es = "Vida baja: subo a evadir ({1})", en = "Low HP, flying to dodge ({1})", zh = "自身低血量 上飞悬空躲避 ({1})", nested = false },
        { es = "Farmeo marino: {1} (llevo {2} s)", en = "Farming sea event: {1} ({2}s)", zh = "刷海上事件: {1} (已打 {2} 秒)", nested = false },
        { es = "Evento marino derrotado: {1}", en = "Sea event defeated: {1}", zh = "海上事件已击败: {1}", nested = false },
        { es = "Mientras espero, farmeo: {1}", en = "Farming event while waiting: {1}", zh = "等待队友期间 刷海上事件: {1}", nested = false },
        { es = "Corazón enganchado (Y={1})", en = "Heart hooked (Y={1})", zh = "心脏已勾中 (Y={1})", nested = false },
        { es = "Atacando al Leviathan: {1}", en = "Attacking the Leviathan: {1}", zh = "攻击利维坦: {1}", nested = false },
        { es = "Receta no encontrada: {1}", en = "Recipe not found: {1}", zh = "配方不存在: {1}", nested = false },
        { es = "Falta progreso {1} ({2}/{3})", en = "Missing progress {1} ({2}/{3})", zh = "进度缺 {1} ({2}/{3})", nested = false },
        { es = "De caza: farmeo {1}", en = "Farming event while hunting: {1}", zh = "寻找利维坦途中 刷海上事件: {1}", nested = false },
        { es = "{1}: fabricado", en = "{1}: crafted", zh = "{1}: 已制作", nested = false },
        { es = "Falta {1} ({2}/{3})", en = "Missing {1} ({2}/{3})", zh = "缺 {1} ({2}/{3})", nested = false },
    }
    local function EscapePattern(text)
        return (text:gsub("([%^%$%(%)%%%.%[%]%*%+%-%?])", "%%%1"))
    end
    local function CompileStatusPattern(template)
        local parts, i = {}, 1
        while true do
            local a, b = template:find("{%d+}", i)
            if not a then
                parts[#parts + 1] = template:sub(i)
                break
            end
            parts[#parts + 1] = template:sub(i, a - 1)
            i = b + 1
        end
        local pattern = "^" .. EscapePattern(parts[1])
        for k = 2, #parts do
            pattern = pattern .. "(.-)" .. EscapePattern(parts[k])
        end
        return pattern .. "$", #parts - 1
    end
    for _, item in ipairs(StatusPatterns) do
        item.pattern, item.slots = CompileStatusPattern(item.es)
    end
    local function TranslateStatic(text, code)
        local entry = StatusStatic[text]
        if entry then
            return entry[code] or entry.en or text
        end
        return text
    end
    local function FillTemplate(template, caps, code, nested)
        local out = template
        for k = 1, #caps do
            local value = caps[k] or ""
            if nested then
                value = TranslateStatic(value, code)
            end
            out = out:gsub("{%d+}", function()
                return value
            end, 1)
        end
        return out
    end
    local StatusCache, StatusCacheCount = {}, 0
    local STATUS_CACHE_MAX = 400
    local function CurrentCode()
        if LanguageCode then
            return LanguageCode()
        end
        return "en"
    end
    local function TranslateStatus(text)
        if text == nil or text == "" then
            return text
        end
        local code = CurrentCode()
        if code == "es" then
            return text
        end
        local cached = StatusCache[text]
        if cached then
            return cached
        end
        local result = TranslateStatic(text, code)
        if result == text then
            for _, item in ipairs(StatusPatterns) do
                local caps = { text:match(item.pattern) }
                if caps[1] ~= nil then
                    result = FillTemplate(item[code] or item.en, caps, code, item.nested)
                    break
                end
            end
        end
        if StatusCacheCount >= STATUS_CACHE_MAX then
            StatusCache, StatusCacheCount = {}, 0
        end
        StatusCache[text] = result
        StatusCacheCount = StatusCacheCount + 1
        return result
    end
    local LastStatusRaw = nil
    local function SetStatus(s)
        LastStatusRaw = s
        local prefix = ""
        if StatusPrefix ~= "" then
            prefix = T("status.prefix.follow") .. " "
        end
        StatusText = prefix .. TranslateStatus(s)
    end
    _G.RJR_RefreshStatus = function()
        if LastStatusRaw then
            SetStatus(LastStatusRaw)
        end
    end
    return TranslateStatus, SetStatus
end)(_G.RJR_LanguageCode)
local ConfigFolder = "MangoJuiceHub"
local ConfigUser = tostring(LocalPlayer and LocalPlayer.Name or "default"):gsub("[^%w_%-]", "_")
local ConfigFile = ConfigFolder .. "/" .. ConfigUser .. "_leviathan_config.json"
local ConfigLegacyFile = ConfigFolder .. "/leviathan_config.json"
local ConfigKeys = {
    "Mode",
    "SilentAim",
    "Language",
    "FollowTarget",
    "SelectWeapon",
    "SkillMelee",
    "SkillSword",
    "SkillFruit",
    "SkillGun",
    "FastAttack",
    "DragonGunFarm",
    "DragonGunLeviathan",
    "RemoveFog",
    "AntiDracoAura",
    "AutoFastMode",
    "FPSBoost",
    "AutoBuso",
    "AutoKen",
    "AutoV3",
    "AutoV4",
    "BoatSpeed",
    "BoatHeight",
    "PlayerTweenSpeed",
    "CruiseReturn",
    "AutoCraftScrolls",
    "CraftQuality",
    "AutoRandomFruit",
    "AutoStoreFruits",
    "HuntFightEvents",
    "SoloSeaFarm",
    "RespawnRebuy",
    "HuntSelectEvents",
    "WebhookURL",
    "WebhookUsername",
    "AutoWebhook",
    "WebhookInterval",
    "WebhookSendProgress",
    "WebhookSendBribeReady",
    "WebhookSendLeviathan",
    "WebhookSendHeartSpawn",
    "WebhookSendHeartGot",
    "WebhookSendLowPlayers",
    "ShowInfoUI",
}
local function EnsureConfigFolder()
    if typeof(isfolder) == "function" and typeof(makefolder) == "function" then
        if not isfolder(ConfigFolder) then
            makefolder(ConfigFolder)
        end
        return true
    end
    return false
end
local function DeepCopy(value)
    if type(value) ~= "table" then
        return value
    end
    local copy = {}
    for k, v in pairs(value) do
        copy[k] = DeepCopy(v)
    end
    return copy
end
local function SaveConfig()
    if not EnsureConfigFolder() then
        return
    end
    if typeof(writefile) ~= "function" then
        return
    end
    local data = {}
    for _, key in ipairs(ConfigKeys) do
        if _G[key] ~= nil then
            data[key] = DeepCopy(_G[key])
        end
    end
    local ok, encoded = pcall(function()
        return HttpService:JSONEncode(data)
    end)
    if ok then
        pcall(function()
            writefile(ConfigFile, encoded)
        end)
    end
end
local function ReadConfigFile(path)
    if typeof(isfile) ~= "function" or typeof(readfile) ~= "function" then
        return false
    end
    if not isfile(path) then
        return false
    end
    local ok, raw = pcall(readfile, path)
    if not (ok and type(raw) == "string" and raw ~= "") then
        return false
    end
    local okDecode, data = pcall(function()
        return HttpService:JSONDecode(raw)
    end)
    if not (okDecode and type(data) == "table") then
        return false
    end
    for _, key in ipairs(ConfigKeys) do
        if data[key] ~= nil then
            _G[key] = data[key]
        end
    end
    return true
end
local function LoadConfig()
    if ReadConfigFile(ConfigFile) then
        return
    end
    if not ReadConfigFile(ConfigLegacyFile) then
        return
    end
    SaveConfig()
    pcall(function()
        if typeof(isfile) == "function" and typeof(delfile) == "function"
            and isfile(ConfigFile) and isfile(ConfigLegacyFile) then
            delfile(ConfigLegacyFile)
        end
    end)
end
LoadConfig()
pcall(function()
    if collectgarbage then
        collectgarbage("setpause", 100)
        collectgarbage("setstepmul", 300)
    end
end)
task.spawn(function()
    while true do
        pcall(collectgarbage, "step", 2)
        task.wait()
    end
end)
do
    local function TravelNumber(value, fallback, minimum, maximum)
        return math.clamp(tonumber(value) or fallback, minimum, maximum)
    end
    _G.BoatSpeed = TravelNumber(_G.BoatSpeed, 250, 50, 500)
    _G.BoatHeight = TravelNumber(_G.BoatHeight, _G.BoatLockY or 150, 30, 500)
    _G.PlayerTweenSpeed = TravelNumber(_G.PlayerTweenSpeed, 275, 50, 500)
    _G.BoatLockY = _G.BoatHeight
end
do
    local vu = game:GetService("VirtualUser")
    AntiAFKConn = LocalPlayer.Idled:Connect(function()
        vu:Button2Down(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
        task.wait(1)
        vu:Button2Up(Vector2.new(0, 0), workspace.CurrentCamera.CFrame)
    end)
end
do
    local function ApplySimulationRadius()
        local ok = pcall(function()
            if type(sethiddenproperty) == "function" then
                sethiddenproperty(LocalPlayer, "SimulationRadius", math.huge)
            else
                LocalPlayer.SimulationRadius = math.huge
            end
        end)
        if not ok then
            pcall(function()
                LocalPlayer.SimulationRadius = math.huge
            end)
        end
    end
    ApplySimulationRadius()
    task.spawn(function()
        while task.wait(1) do
            ApplySimulationRadius()
        end
    end)
end
task.spawn(function()
    while true do
        pcall(function()
            local rocks = workspace:FindFirstChild("Rocks")
            if rocks then
                rocks:Destroy()
                print("[Leviathan] workspace.Rocks eliminado")
            end
        end)
        task.wait(0.5)
    end
end)
if Character == nil then
    Character = LocalPlayer.Character or LocalPlayer.CharacterAdded:Wait()
    HD = Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid")
    HRP = Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart")
end
local function GetCharacterParts()
    local char = LocalPlayer.Character
    if not char then
        return nil, nil, nil
    end
    return char, char:FindFirstChild("HumanoidRootPart"), char:FindFirstChildOfClass("Humanoid")
end
local NoclipOn = false
local LastNoclipApply = 0
local function NoClip(v)
    if not Character or not HRP or not HD or HD.Health <= 0 then
        return
    end
    if v then
        if NoclipOn and os.clock() - LastNoclipApply < 0.5 then
            return
        end
        NoclipOn = true
        LastNoclipApply = os.clock()
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = false
            end
        end
    else
        NoclipOn = false
        for _, part in pairs(Character:GetDescendants()) do
            if part:IsA("BasePart") then
                part.CanCollide = true
            end
        end
    end
end
local Tweening = false
local TWEEN_PART_NAME = "OptimizedTweenPart"
local HoldCFrame = nil
local LiveHoldFn = nil
local TpActive = false
local function GetTweenPart()
    local part = workspace:FindFirstChild(TWEEN_PART_NAME)
    if part and part:IsA("BasePart") then
        return part
    end
    part = Instance.new("Part")
    part.Name = TWEEN_PART_NAME
    part.Size = Vector3.new(1, 1, 1)
    part.Anchored = true
    part.CanCollide = false
    part.CanTouch = false
    part.CanQuery = false
    part.CastShadow = false
    part.Massless = true
    part.Transparency = 1
    part.Parent = workspace
    return part
end
local function _tp(targetPos, abortCheck)
    local startChar = LocalPlayer.Character
    local myHRP = select(2, GetCharacterParts())
    if not myHRP then
        return false
    end
    if _G.StopTween then
        return false
    end
    local targetCFrame, liveTarget
    if typeof(targetPos) == "function" then
        targetCFrame = targetPos()
        if not targetCFrame then
            return false
        end
        liveTarget = targetPos
    elseif typeof(targetPos) == "Vector3" then
        targetCFrame = CFrame.new(targetPos)
    elseif typeof(targetPos) == "CFrame" then
        targetCFrame = targetPos
    elseif typeof(targetPos) == "Instance" and targetPos:IsA("BasePart") then
        targetCFrame = targetPos.CFrame
    else
        return false
    end
    if targetCFrame.Position.Y < 0 then
        return false
    end
    HoldCFrame = nil
    LiveHoldFn = nil
    if not liveTarget then
        local h2 = select(2, GetCharacterParts())
        if not h2 then
            return false
        end
        myHRP = h2
    end
    local SeatNearTarget = function(seat)
        if not seat or not seat.Parent then
            return false
        end
        local tgt
        if liveTarget then
            local ok, cf = pcall(liveTarget)
            tgt = ok and cf or nil
        else
            tgt = targetCFrame
        end
        if not tgt then
            return false
        end
        return (seat.Position - tgt.Position).Magnitude <= 40
    end
    local _, _, humPre = GetCharacterParts()
    if humPre and humPre.SeatPart and SeatNearTarget(humPre.SeatPart) then
        return true
    end
    local _, _, humS = GetCharacterParts()
    if humS and (humS.Sit or humS.SeatPart ~= nil) then
        pcall(function()
            humS.Sit = false
            humS.PlatformStand = false
        end)
        pcall(function()
            myHRP.CFrame = myHRP.CFrame + Vector3.new(0, 10, 0)
        end)
        task.wait(0.2)
    end
    local part = GetTweenPart()
    part.CFrame = myHRP.CFrame
    NoClip(true)
    local tweenSpeed = _G.PlayerTweenSpeed or 140
    if CurrentTween then
        pcall(function()
            CurrentTween:Cancel()
        end)
        CurrentTween = nil
    end
    local tween = nil
    if not liveTarget then
        local distance = (targetCFrame.Position - myHRP.Position).Magnitude
        local duration = math.max(distance / tweenSpeed, 0.05)
        tween = TweenService:Create(part,
            TweenInfo.new(duration, Enum.EasingStyle.Linear, Enum.EasingDirection.Out),
            { CFrame = targetCFrame })
        CurrentTween = tween
    end
    Tweening = true
    TpActive = true
    local aborted = false
    local arrived = false
    local seatedStop = false
    local nextAbortAt = 0
    local connection
    connection = RunService.Stepped:Connect(function(_, deltaTime)
        local dt = deltaTime or (1 / 60)
        local curChar = LocalPlayer.Character
        local curHum = curChar and curChar:FindFirstChildOfClass("Humanoid")
        local curHRP = select(2, GetCharacterParts())
        if not curHRP or curChar ~= startChar or not curHum or curHum.Health <= 0 then
            aborted = true
            if tween then
                tween:Cancel()
            end
        elseif curHRP.Position.Y < 0 then
            aborted = true
            if tween then
                tween:Cancel()
            end
        else
            if not seatedStop and curHum.SeatPart ~= nil then
                seatedStop = true
                arrived = true
                if tween then
                    tween:Cancel()
                end
            end
            if not seatedStop then
                if liveTarget then
                    local tgt = liveTarget()
                    if tgt and tgt.Position.Y < 0 then
                        aborted = true
                        if tween then
                            tween:Cancel()
                        end
                    elseif tgt then
                        local cur = part.Position
                        local delta = tgt.Position - cur
                        local dist = delta.Magnitude
                        if dist <= 5 then
                            arrived = true
                        else
                            part.CFrame = CFrame.new(cur + delta.Unit * math.min(dist, tweenSpeed * dt))
                                * (part.CFrame - part.CFrame.Position)
                        end
                    end
                end
                if not aborted then
                    curHRP.CFrame = part.CFrame
                    curHRP.AssemblyLinearVelocity = Vector3.zero
                    for _, p in ipairs(curChar:GetDescendants()) do
                        if p:IsA("BasePart") then
                            p.CanCollide = false
                        end
                    end
                end
            end
        end
        if abortCheck and not aborted then
            local now = tick()
            if now >= nextAbortAt then
                nextAbortAt = now + 0.1
                local ok, stop = pcall(abortCheck)
                if ok and stop then
                    aborted = true
                    if tween then
                        tween:Cancel()
                    end
                end
            end
        end
    end)
    pcall(function()
        if liveTarget then
            local timeout = tick()
                + math.max(8, (targetCFrame.Position - myHRP.Position).Magnitude / tweenSpeed + 8)
            repeat
                task.wait()
            until arrived or aborted or tick() > timeout
        elseif tween then
            tween:Play()
            repeat
                task.wait()
                if seatedStop or aborted then
                    break
                end
            until tween.PlaybackState ~= Enum.PlaybackState.Playing
        end
    end)
    pcall(function()
        connection:Disconnect()
    end)
    if tween and CurrentTween == tween then
        CurrentTween = nil
    end
    Tweening = false
    TpActive = false
    if not aborted and not seatedStop then
        if liveTarget then
            LiveHoldFn = liveTarget
            HoldCFrame = nil
        else
            LiveHoldFn = nil
            HoldCFrame = targetCFrame
        end
    end
    return not aborted
end
local function HoverSpeedNow()
    return _G.PlayerTweenSpeed or 140
end
local function ClearHover()
    HoldCFrame = nil
    LiveHoldFn = nil
end
RunService.Heartbeat:Connect(function(dt)
    if _G.StopTween then
        return
    end
    local _, hrp, hum = GetCharacterParts()
    if not hrp then
        return
    end
    if hum and hum.SeatPart ~= nil then
        return
    end
    if TpActive then
        return
    end
    if CurrentTween and CurrentTween.PlaybackState == Enum.PlaybackState.Playing then
        return
    end
    local goal = nil
    if AttackModel then
        if not AttackModel.Parent then
            AttackModel, AttackStandFn = nil, nil
        else
            local ok, cf = pcall(AttackStandFn)
            if ok and cf and cf.Position.Y < 0 then
                cf = nil
                AttackModel, AttackStandFn = nil, nil
            end
            if ok and cf then
                goal = cf
                if FightTarget then
                    FightTarget.CF = cf
                    FightTarget.At = os.clock()
                end
            end
        end
    end
    if not goal and LiveHoldFn then
        local ok, cf = pcall(LiveHoldFn)
        if ok and cf then
            if cf.Position.Y < 0 then
                ClearHover()
                return
            end
            goal = cf
        end
    end
    if not goal then
        goal = HoldCFrame
        if goal and goal.Position.Y < 0 then
            ClearHover()
            return
        end
    end
    if not goal then
        return
    end
    if not LiveHoldFn then
        HoldCFrame = goal
    end
    hrp.AssemblyLinearVelocity = Vector3.zero
    hrp.AssemblyAngularVelocity = Vector3.zero
    local char = LocalPlayer.Character
    if char then
        for _, p in ipairs(char:GetDescendants()) do
            if p:IsA("BasePart") then
                p.CanCollide = false
            end
        end
    end
    local dist = (goal.Position - hrp.Position).Magnitude
    if dist <= 3 then
        hrp.CFrame = goal
    else
        local step = math.min(dist, HoverSpeedNow() * (dt or (1 / 60)))
        hrp.CFrame = hrp.CFrame:Lerp(goal, step / dist)
    end
end)
local function StopTweenAll()
    _G.StopTween = true
    if CurrentTween then
        pcall(function()
            CurrentTween:Cancel()
        end)
        CurrentTween = nil
    end
    Tweening = false
    TpActive = false
    NoClip(false)
    ClearHover()
    task.defer(function()
        task.wait(0.1)
        _G.StopTween = false
    end)
end
do
local SeatPhantomState = {
    since = setmetatable({}, { __mode = "k" }),
    grace = 2,
}
local function SeatTakenByOther(seat, hum)
    local Occupant = seat.Occupant
    if Occupant ~= nil and Occupant ~= hum then
        return true
    end
    local Weld = seat:FindFirstChild("SeatWeld")
    if Weld then
        local p1 = Weld.Part1
        if p1 and p1:IsA("BasePart") then
            local owner = p1:FindFirstAncestorWhichIsA("Model")
            local otherHum = owner and owner:FindFirstChildOfClass("Humanoid")
            if otherHum and otherHum ~= hum then
                return true
            end
        end
    end
    return false
end
_G.RJR_SeatTakenByOther = SeatTakenByOther
local SEAT_DRIFT = 60
local BODY_STILL = 30
_G.RJR_SeatConfirmed = function(seat)
    local _, hrp, hum = GetCharacterParts()
    if not hum or not seat or not seat.Parent then
        return false
    end
    if hum.SeatPart ~= seat then
        return false
    end
    if SeatTakenByOther(seat, hum) then
        return false
    end
    if not hrp then
        return true
    end
    local st = SeatPhantomState.since[seat]
    if not st then
        SeatPhantomState.since[seat] = { seatPos = seat.Position, bodyPos = hrp.Position, at = os.clock() }
        return true
    end
    local seatMoved = (seat.Position - st.seatPos).Magnitude
    local bodyMoved = (hrp.Position - st.bodyPos).Magnitude
    if seatMoved > SEAT_DRIFT and bodyMoved < BODY_STILL then
        if os.clock() - st.at >= SeatPhantomState.grace then
            return false
        end
    elseif os.clock() - st.at >= SeatPhantomState.grace then
        st.seatPos, st.bodyPos, st.at = seat.Position, hrp.Position, os.clock()
    end
    return true
end
_G.RJR_BreakPhantomSeat = function(seat)
    local char, hrp, hum = GetCharacterParts()
    if not hum then
        return false
    end
    local Target = seat or hum.SeatPart
    pcall(function()
        hum.Sit = false
        hum.PlatformStand = false
    end)
    if Target and Target.Parent then
        local Weld = Target:FindFirstChild("SeatWeld")
        local p1 = Weld and Weld.Part1
        if Weld and ((not p1) or (p1:IsA("BasePart") and char and p1:IsDescendantOf(char))) then
            pcall(function()
                Weld:Destroy()
            end)
        end
    end
    if hrp then
        pcall(function()
            hrp.CFrame = hrp.CFrame + Vector3.new(0, 5, 0)
            hrp.AssemblyLinearVelocity = Vector3.zero
            hrp.AssemblyAngularVelocity = Vector3.zero
        end)
    end
    ClearHover()
    if Target then
        SeatPhantomState.since[Target] = nil
    end
    task.wait(0.15)
    local _, _, hum2 = GetCharacterParts()
    return hum2 == nil or not hum2.Sit
end
end
local function CheckItem(Item, Mode)
    if not Character or not HRP or not HD then
        return nil
    end
    if Mode == "Find" then
        for _, v in ipairs(Character:GetChildren()) do
            if string.find(v.Name, Item, 1, true) then
                return v
            end
        end
        for _, v in ipairs(LocalPlayer.Backpack:GetChildren()) do
            if string.find(v.Name, Item, 1, true) then
                return v
            end
        end
    else
        return Character:FindFirstChild(Item) or LocalPlayer.Backpack:FindFirstChild(Item)
    end
end
local function CheckSkill(Weapon, Key)
    local ok, result = pcall(function()
        local Item = CheckItem(Weapon)
        if not Item then
            return false
        end
        local Weapon2 = Item.ToolTip
        local Skills = nil
        if Weapon2 == "Melee" then
            Skills = _G.SkillMelee
        elseif Weapon2 == "Sword" then
            Skills = _G.SkillSword
        elseif Weapon2 == "Blox Fruit" then
            Skills = _G.SkillFruit
        elseif Weapon2 == "Gun" then
            Skills = _G.SkillGun
        end
        if not Skills then
            return false
        end
        for _, v in ipairs(Skills) do
            if v == Key then
                return true
            end
        end
        return false
    end)
    return ok and result
end
local function Equip_Auto(Tool)
    if not Character or not HRP or not HD then
        return
    end
    if HD.Health > 0 and LocalPlayer:FindFirstChild("Backpack") then
        if Tool == "Melee" or Tool == "Sword" or Tool == "Gun" or Tool == "Blox Fruit" then
            for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                if v.ToolTip == Tool then
                    HD:EquipTool(v)
                    break
                end
            end
        else
            for i, v in pairs(LocalPlayer.Backpack:GetChildren()) do
                if v.Name == Tool then
                    HD:EquipTool(v)
                    break
                end
            end
        end
    end
end
local function Skill_Auto(Key)
    local Code
    if Key == "Space" then
        Code = Enum.KeyCode.Space
    else
        Code = Enum.KeyCode[Key:upper()]
    end
    if not Code then
        return
    end
    VirtualInputManager:SendKeyEvent(true, Code, false, game)
    task.wait(0.1)
    VirtualInputManager:SendKeyEvent(false, Code, false, game)
end
local function CoolDown_Chack(Cooldown)
    if LocalPlayer.Data.Race == "Ghoul"
    and LocalPlayer.PlayerGui.Main.BottomHUDList.UniversalContextButtons:FindFirstChild("BoundActionRaceAbility")
    and tonumber(LocalPlayer.PlayerGui.Main.BottomHUDList.UniversalContextButtons.BoundActionRaceAbility.CooldownLabel.Text) >= 22
    and Cooldown.Size.X.Scale <= 0.4 then
        return true
    end
    return Cooldown.Size.X.Scale == 0
end
local function CoolDown_Auto()
    if SkillCoolDown then
        return
    end
    if tick() - LastAllWeapon >= 10 then
        SkillCoolDown = true
        LastAllWeapon = tick()
        Equip_Auto("Melee")
        task.wait()
        Equip_Auto("Sword")
        task.wait()
        Equip_Auto("Gun")
        task.wait()
        Equip_Auto("Blox Fruit")
        task.wait(0.5)
        SkillCoolDown = false
    end
    local Skills = LocalPlayer.PlayerGui.Main.Skills
    for _, Weapon in pairs(Skills:GetChildren()) do
        for _, v in pairs(Weapon:GetChildren()) do
            if table.find({"Z", "X", "C", "V", "F"}, v.Name) then
                local Key = v.Name
                local Cooldown = v:FindFirstChild("Cooldown", true)
                local Level = v:FindFirstChild("Level")
                local Item = CheckItem(Weapon.Name)
                if Cooldown and Level and Item and CheckSkill(Weapon.Name, Key) then
                    if CoolDown_Chack(Cooldown)
                    and tonumber(Level.Text:match("%d+")) <= Item.Level.Value then
                        task.spawn(function()
                            SkillCoolDown = true
                            Equip_Auto(Weapon.Name)
                            Skill_Auto(Key)
                            task.wait(0.5)
                            SkillCoolDown = false
                        end)
                    end
                end
            end
        end
    end
end
local function Haki_Auto()
    if not _G.AutoBuso then
        return
    end
    if Character and HRP then
        if not Character:FindFirstChild("HasBuso") then
            pcall(function()
                CommF:InvokeServer("Buso")
            end)
        end
    end
end
local function CheckSkillTable(v)
    local result = {}
    if type(v) == "table" then
        local isArray = #v > 0
        if isArray then
            for _, v in ipairs(v) do
                if type(v) == "string" and v ~= "" then
                    result[#result + 1] = v
                end
            end
        else
            for k, v in pairs(v) do
                if v == true and type(k) == "string" then
                    result[#result + 1] = k
                elseif type(v) == "string" and v ~= "" then
                    result[#result + 1] = v
                end
            end
        end
    elseif type(v) == "string" and v ~= "" then
        result[1] = v
    end
    return result
end
local function Attack_Clone(inst)
    if typeof(cloneref) == "function" then
        return cloneref(inst)
    end
    return inst
end
local function Attack_CaptureRemote(R)
    if R and R:IsA("RemoteEvent") and R:GetAttribute("Id") then
        AttackObfuscatedRemote = R
        AttackObfuscatedId = R:GetAttribute("Id")
    end
end
do
    local folders = {"Util", "Common", "Remotes", "Assets", "FX"}
    for _, name in ipairs(folders) do
        local folder = RS:FindFirstChild(name)
        if folder then
            for _, child in ipairs(folder:GetChildren()) do
                Attack_CaptureRemote(child)
            end
            folder.ChildAdded:Connect(function(child)
                Attack_CaptureRemote(child)
            end)
        end
    end
end
local function Attack_EnsureRemotes()
    if not AttackNet then
        local modules = RS:FindFirstChild("Modules")
        AttackNet = modules and modules:FindFirstChild("Net")
    end
    if not AttackNet then
        return false
    end
    if not AttackRegisterAttack then
        AttackRegisterAttack = AttackNet:FindFirstChild("RE/RegisterAttack") or AttackNet:FindFirstChild("RegisterAttack")
    end
    if not AttackRegisterHit then
        AttackRegisterHit = AttackNet:FindFirstChild("RE/RegisterHit") or AttackNet:FindFirstChild("RegisterHit")
    end
    if not AttackSeedRemote then
        AttackSeedRemote = AttackNet:FindFirstChild("seed")
    end
    return AttackRegisterAttack ~= nil and AttackRegisterHit ~= nil
end
local AttackHitCache, AttackHitOrigin, AttackHitAt
local function Attack_BuildHitList(character, origin)
    local now = os.clock()
    if AttackHitCache and AttackHitOrigin
        and (now - AttackHitAt) < 0.1
        and (origin - AttackHitOrigin).Magnitude < 40 then
        return AttackHitCache
    end
    local hitList = AttackHitCache or {}
    table.clear(hitList)
    local folders = {workspace:FindFirstChild("Enemies"), workspace:FindFirstChild("Characters")}
    for _, folder in ipairs(folders) do
        if folder then
            for _, model in ipairs(folder:GetChildren()) do
                if model ~= character then
                    local root = model:FindFirstChild("HumanoidRootPart")
                    local hum = model:FindFirstChild("Humanoid")
                    if root and hum and hum.Health > 0 and (root.Position - origin).Magnitude <= 60 then
                        for _, part in ipairs(model:GetChildren()) do
                            if part:IsA("BasePart") then
                                hitList[#hitList + 1] = {model, part}
                            end
                        end
                    end
                end
            end
        end
    end
    AttackHitCache, AttackHitOrigin, AttackHitAt = hitList, origin, now
    return hitList
end
local function Attack_GetSeed()
    local now = os.clock()
    if AttackSeedCache and (now - AttackSeedAt) < 1 then
        return AttackSeedCache
    end
    if AttackSeedRemote then
        local ok, seed = pcall(function()
            return AttackSeedRemote:InvokeServer()
        end)
        if ok and seed then
            AttackSeedCache = seed
            AttackSeedAt = now
            return seed
        end
    end
    return AttackSeedCache or 1
end
local function Attack_Auto()
    if not Character or not HRP or not HD then
        return
    end
    local tool = Character:FindFirstChildOfClass("Tool")
    if not tool then
        return
    end
    local WT = tool:GetAttribute("WeaponType")
    if WT ~= "Melee" and WT ~= "Sword" then
        return
    end
    if not Attack_EnsureRemotes() then
        return
    end
    local hitList = Attack_BuildHitList(Character, HRP.Position)
    if #hitList == 0 then
        return
    end
    pcall(function()
        local okNet, netApi = pcall(function()
            return require(AttackNet)
        end)
        if okNet and netApi and netApi.RemoteEvent then
            pcall(netApi.RemoteEvent, netApi, "RegisterHit", true)
        end
        AttackRegisterAttack:FireServer()
        local primaryModel = hitList[1][1]
        local head = primaryModel and primaryModel:FindFirstChild("Head")
        if not head then
            return
        end
        if _G.FastAttack_Mode == "1" then
            AttackRegisterHit:FireServer(head, hitList)
        else
            AttackRegisterHit:FireServer(head, hitList, {}, tostring(LocalPlayer.UserId):sub(2, 4) ..
                tostring(coroutine.running()):sub(11, 15))
        end
        if AttackObfuscatedRemote and AttackObfuscatedId then
            local key = math.floor(workspace:GetServerTimeNow() / 10 % 10) + 1
            local encName = string.gsub("RE/RegisterHit", ".", function(c)
                return string.char(bit32.bxor(string.byte(c), key))
            end)
            local encId = bit32.bxor(AttackObfuscatedId + 909090, Attack_GetSeed() * 2)
            Attack_Clone(AttackObfuscatedRemote):FireServer(encName, encId, head, hitList)
        end
    end)
end
local function TargetPos(inst)
    if not inst then
        return nil
    end
    if inst:IsA("BasePart") then
        return inst.Position
    end
    if inst:IsA("Model") then
        local primary = inst.PrimaryPart
        if primary then
            return primary.Position
        end
        local part = inst:FindFirstChildWhichIsA("BasePart")
        if part then
            return part.Position
        end
    end
    local ok, center = pcall(function()
        return inst:GetBoundingBox()
    end)
    if ok and center then
        return center.Position
    end
    return nil
end
local HeartPosCache = { inst = nil, part = nil }
local function GetHeartPos(Heart)
    if not Heart then
        return nil
    end
    if HeartPosCache.inst ~= Heart then
        HeartPosCache.inst = Heart
        HeartPosCache.part = nil
    end
    local part = HeartPosCache.part
    if not part or not part.Parent then
        if Heart:IsA("BasePart") then
            part = Heart
        elseif Heart:IsA("Model") then
            part = Heart.PrimaryPart
                or Heart:FindFirstChildWhichIsA("BasePart")
                or Heart:FindFirstChildWhichIsA("BasePart", true)
        end
        HeartPosCache.part = part
    end
    if part and part.Parent then
        return part.Position
    end
    return nil
end
local function Leviathan_CommF()
    local CommF2 = CommF
    if not CommF2 then
        local remotes = RS:FindFirstChild("Remotes")
        CommF2 = remotes and remotes:FindFirstChild("CommF_")
    end
    return CommF2
end
local BribeCache = nil
local BribeCacheAt = 0
local function GetBribeStatus()
    if BribeCache and os.clock() - BribeCacheAt < 2 then
        return BribeCache
    end
    local CommF2 = Leviathan_CommF()
    if not CommF2 then
        return nil
    end
    local ok, result = pcall(function()
        return CommF2:InvokeServer("InfoLeviathan", "1")
    end)
    if ok then
        local n = tonumber(result)
        if n then
            BribeCache = n
            BribeCacheAt = os.clock()
            return n
        end
        BribeCache = 5
        BribeCacheAt = os.clock()
        return 5
    end
    return nil
end
local function DoBribe()
    local CommF2 = Leviathan_CommF()
    if not CommF2 then
        return nil
    end
    local ok, result = pcall(function()
        return CommF2:InvokeServer("InfoLeviathan", "2")
    end)
    if ok then
        return result
    end
    return nil
end
local function BribeUntilDone()
    local S0 = GetBribeStatus()
    if S0 == 5 or S0 == -1 or S0 == nil then
        return
    end
    for i = 1, 4 do
        SetStatus("Sobornando al espía (intento " .. i .. "/4)")
        DoBribe()
        task.wait(0.5)
        local S = GetBribeStatus()
        if S == 5 or S == -1 or S == nil then
            break
        end
    end
end
local BoatDealerCF = CFrame.new(-16917.1523, 8.59936905, 511.799042)
local BoatFindRange = 5000
local CruiseWP_A = CFrame.new(-44541.7617, 30.0003204, -1244.8584)
local CruiseWP_B = CFrame.new(-90000, 30.0003204, -1244.8584)
local CruiseWP_Far = CFrame.new(-9000000000, 30.0003204, -1244.8584)
local SailArriveDist = 40
local function IsBeastHunterBoat(boat)
    if not boat then
        return false
    end
    return boat.Name == "Beast Hunter"
end
local function BoatOwnerMatch(boat, player)
    local Owner = boat and boat:FindFirstChild("Owner")
    if not Owner or not player then
        return false
    end
    if Owner.Value == player then
        return true
    end
    if typeof(Owner.Value) == "string" and Owner.Value == player.Name then
        return true
    end
    if tostring(Owner.Value) == player.Name then
        return true
    end
    return false
end
local function BoatOf(seat)
    local node = seat
    while node do
        if node.Parent and node.Parent.Name == "Boats" then
            return node
        end
        node = node.Parent
    end
    return nil
end
local function AbandonIfTooFar(seat)
    if not seat or not seat.Parent then
        return false
    end
    local boat = BoatOf(seat)
    if not boat or not IsBeastHunterBoat(boat) then
        return false
    end
    if not BoatOwnerMatch(boat, LocalPlayer) then
        return false
    end
    local _, hrp = GetCharacterParts()
    if not hrp then
        return false
    end
    if (hrp.Position - seat.Position).Magnitude > BoatFindRange then
        _G.RJR_AbandonedBoats[boat] = true
        SetStatus("Barco a más de " .. BoatFindRange .. ", lo abandono y compro otro")
        print("[Leviathan] Barco fuera de rango, abandonado: " .. boat.Name)
        return true
    end
    return false
end
local function IsBoatDead(boat)
    if not boat then
        return false
    end
    local Humanoid = boat:FindFirstChild("Humanoid")
    if Humanoid then
        if Humanoid:IsA("ValueBase") then
            local ok, v = pcall(function()
                return Humanoid.Value
            end)
            if ok and v ~= nil then
                return v <= 0
            end
        elseif Humanoid:IsA("Humanoid") then
            return Humanoid.Health <= 0
        end
    end
    local Health = boat:FindFirstChild("Health")
    if Health and Health:IsA("ValueBase") then
        local ok2, v2 = pcall(function()
            return Health.Value
        end)
        if ok2 and v2 ~= nil then
            return v2 <= 0
        end
    end
    local HRPValue = boat:FindFirstChild("HumanoidRootPart")
    if HRPValue and HRPValue:IsA("ValueBase") then
        local ok3, v3 = pcall(function()
            return HRPValue.Value
        end)
        if ok3 and v3 ~= nil then
            return v3 <= 0
        end
    end
    return false
end
_G.RJR_AbandonedBoats = _G.RJR_AbandonedBoats or setmetatable({}, { __mode = "k" })
local function OwnedBoatsOf(player)
    local result = {}
    local boats = workspace:FindFirstChild("Boats")
    if not boats or not player then
        return result
    end
    for _, boat in ipairs(boats:GetChildren()) do
        if IsBeastHunterBoat(boat) and BoatOwnerMatch(boat, player)
        and not _G.RJR_AbandonedBoats[boat] then
            table.insert(result, boat)
        end
    end
    return result
end
local function OwnBoatUnusable(player, isCrew)
    if _G.RJR_Resetting then
        return true
    end
    local boats = OwnedBoatsOf(player)
    if #boats == 0 then
        return false
    end
    local _, hrp = GetCharacterParts()
    if not hrp and not isCrew then
        return false
    end
    for _, boat in ipairs(boats) do
        if not IsBoatDead(boat) then
            if isCrew then
                return false
            end
            local seat = boat:FindFirstChild("VehicleSeat") or boat:FindFirstChildWhichIsA("BasePart", true)
            if hrp and seat and (seat.Position - hrp.Position).Magnitude <= BoatFindRange then
                return false
            end
        end
    end
    return true
end
local function GetOwnBoat(includeDead)
    local boats = workspace:FindFirstChild("Boats")
    if not boats then
        return nil
    end
    local _, hrp = GetCharacterParts()
    local myPos = hrp and hrp.Position
    if not myPos then
        return nil
    end
    for _, boat in ipairs(boats:GetChildren()) do
        local owner = boat:FindFirstChild("Owner")
        if owner and (owner.Value == LocalPlayer or tostring(owner.Value) == LocalPlayer.Name) then
            if (includeDead or not IsBoatDead(boat)) and not _G.RJR_AbandonedBoats[boat] then
                local seat = boat:FindFirstChild("VehicleSeat") or boat.PrimaryPart
                    or boat:FindFirstChildWhichIsA("BasePart", true)
                if seat and (seat.Position - myPos).Magnitude <= BoatFindRange then
                    return boat
                end
                _G.RJR_AbandonedBoats[boat] = true
                print("[Leviathan] Barco fuera de rango, abandonado: " .. boat.Name)
            end
        end
    end
    return nil
end
local function GetCaptainBoat()
    local boats = workspace:FindFirstChild("Boats")
    if not boats then
        return nil
    end
    local captain = Players:FindFirstChild(_G.FollowTarget)
    if not captain then
        return nil
    end
    local _, hrp = GetCharacterParts()
    local myPos = hrp and hrp.Position
    if not myPos then
        return nil
    end
    for _, boat in ipairs(boats:GetChildren()) do
        local owner = boat:FindFirstChild("Owner")
        if owner and (owner.Value == captain or tostring(owner.Value) == captain.Name)
        and not _G.RJR_AbandonedBoats[boat] then
            if not IsBoatDead(boat) then
                local seat = boat:FindFirstChild("VehicleSeat") or boat.PrimaryPart
                    or boat:FindFirstChildWhichIsA("BasePart", true)
                if seat and (seat.Position - myPos).Magnitude <= BoatFindRange then
                    return boat
                end
            end
        end
    end
    return nil
end
local function GetCaptainHRP()
    local captain = Players:FindFirstChild(_G.FollowTarget)
    local char = captain and captain.Character
    return char and char:FindFirstChild("HumanoidRootPart")
end
local function KeepFacing()
    local _, hrpNow = GetCharacterParts()
    if hrpNow then
        return hrpNow.CFrame - hrpNow.CFrame.Position
    end
    return CFrame.new()
end
local function LiveSeatCF(seat)
    return function()
        if not seat or not seat.Parent then
            return nil
        end
        return seat.CFrame
    end
end
local function LiveCaptainTopCF(height)
    return function()
        local capHrp = GetCaptainHRP()
        if not capHrp then
            return nil
        end
        return CFrame.new(capHrp.Position + Vector3.new(0, height or 35, 0)) * KeepFacing()
    end
end
local function LiveHeartCF(height)
    return function()
        local Map = workspace:FindFirstChild("Map")
        local Heart = Map and Map:FindFirstChild("FrozenHeart")
        local hp = Heart and GetHeartPos(Heart)
        if not hp then
            return nil
        end
        return (CFrame.new(hp) * CFrame.new(0, height or 35, 0)) * KeepFacing()
    end
end
local function LiveGateCF(height)
    return function()
        local Map = workspace:FindFirstChild("Map")
        local Gate = Map and Map:FindFirstChild("LeviathanGate")
        local Watcher = Gate and Gate:FindFirstChild("FrozenWatcherPart")
        local wp = Watcher and TargetPos(Watcher)
        if not wp then
            return nil
        end
        return (CFrame.new(wp) * CFrame.new(0, height or 5, 0)) * KeepFacing()
    end
end
local function LiveSelfCF(minY)
    return function()
        local _, hrp = GetCharacterParts()
        if not hrp then
            return nil
        end
        return CFrame.new(hrp.Position.X, math.max(hrp.Position.Y, minY or 50), hrp.Position.Z) * KeepFacing()
    end
end
local function LiveFixedCF(cf)
    return function()
        return cf
    end
end
_G.RJR_KenLoopGen = 0
_G.RJR_StartKenLoop = function()
    _G.RJR_KenLoopGen = _G.RJR_KenLoopGen + 1
    local myGen = _G.RJR_KenLoopGen
    task.spawn(function()
        while _G.RJR_KenLoopGen == myGen do
            task.wait(5)
            if _G.AutoKen then
                pcall(function()
                    local Remotes = RS:FindFirstChild("Remotes")
                    local CommE2 = Remotes and Remotes:FindFirstChild("CommE")
                    if CommE2 then
                        CommE2:FireServer("Ken", true)
                    end
                end)
            end
        end
    end)
end
_G.RJR_StartKenLoop()
local function GetCannons(boat)
    local cannons = {}
    if boat then
        for _, child in ipairs(boat:GetChildren()) do
            if child.Name == "Cannon" then
                table.insert(cannons, child)
            end
        end
    end
    return cannons
end
local function IsSeatOccupied(seat)
    if not seat then
        return false
    end
    local Weld = seat:FindFirstChild("SeatWeld")
    if Weld then
        local p1 = Weld.Part1
        if p1 and p1:IsA("BasePart") and p1:IsDescendantOf(workspace) then
            local ownerChar = p1:FindFirstAncestorWhichIsA("Model")
            local hum = ownerChar and ownerChar:FindFirstChildOfClass("Humanoid")
            if hum and hum.Health > 0 then
                return true
            end
        end
        pcall(function()
            Weld:Destroy()
        end)
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        local hum = char and char:FindFirstChildOfClass("Humanoid")
        if hum and hum.SeatPart == seat and hum.Sit then
            return true
        end
    end
    return false
end
local function CountTeammatesOnBoat(boat)
    if not boat or not boat.Parent then
        return 0
    end
    local Count = 0
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            local hum = char and char:FindFirstChildOfClass("Humanoid")
            local seat = hum and hum.SeatPart
            if seat and seat.Parent and seat:IsDescendantOf(boat) and hum.Sit then
                Count = Count + 1
            end
        end
    end
    if Count == 0 then
        for _, cannon in ipairs(GetCannons(boat)) do
            local seat = cannon:FindFirstChild("Seat")
            if IsSeatOccupied(seat) then
                Count = Count + 1
            end
        end
    end
    return Count
end
local function IsSittingOn(seat)
    local _, _, hum = GetCharacterParts()
    if not hum or not seat or not seat.Parent then
        return false
    end
    return hum.SeatPart == seat
end
local function IsOnBoat()
    local _, _, hum = GetCharacterParts()
    return hum ~= nil and (hum.SeatPart ~= nil or hum.Sit)
end
local RestoreWallClip = nil
local function Unseat()
    if RestoreWallClip then
        pcall(RestoreWallClip)
    end
    ClearHover()
    for _ = 1, 3 do
        local _, hrp, hum = GetCharacterParts()
        if not hum or (not hum.Sit and hum.SeatPart == nil) then
            return true
        end
        pcall(function()
            local char = LocalPlayer.Character
            local seat = hum and hum.SeatPart
            if char and seat and seat.Parent then
                local Weld = seat:FindFirstChild("SeatWeld")
                local p1 = Weld and Weld.Part1
                if Weld and ((not p1) or (p1:IsA("BasePart") and p1:IsDescendantOf(char))) then
                    Weld:Destroy()
                end
            end
        end)
        if hum then
            pcall(function()
                hum.Sit = false
                hum.PlatformStand = false
            end)
        end
        if hrp then
            pcall(function()
                hrp.CFrame = hrp.CFrame + Vector3.new(0, 10, 0)
            end)
        end
        local UnseatStart = os.clock()
        while os.clock() - UnseatStart < 2 do
            local _, _, hum2 = GetCharacterParts()
            if hum2 and (hum2.Sit or hum2.SeatPart ~= nil) then
                pcall(function()
                    hum2.Sit = false
                    hum2.PlatformStand = false
                end)
                task.wait(0.2)
            else
                return true
            end
        end
    end
    return false
end
local function BoardSeat(seat, timeout)
    timeout = timeout or 15
    if not seat or not seat.Parent then
        return false
    end
    if AbandonIfTooFar(seat) then
        return false
    end
    local start = os.clock()
    local Deadline = start + timeout
    while _G.AutoLeviathanFull and os.clock() < Deadline do
        if not seat or not seat.Parent then
            return false
        end
        if AbandonIfTooFar(seat) then
            return false
        end
        local _, hrp, hum = GetCharacterParts()
        if hum and hum.SeatPart == seat then
            ClearHover()
            _G.RJR_BoardStall = nil
            return true
        end
        if hum and (hum.Sit or hum.SeatPart ~= nil) then
            Unseat()
            task.wait(0.3)
        end
        if hrp then
            if (hrp.Position - seat.Position).Magnitude <= BoatFindRange then
                local Stall = _G.RJR_BoardStall
                local DSeat = (hrp.Position - seat.Position).Magnitude
                if DSeat > 15 and not TpActive and not Tweening then
                    if not Stall then
                        _G.RJR_BoardStall = { pos = hrp.Position, at = os.clock() }
                    elseif (hrp.Position - Stall.pos).Magnitude > 3 then
                        Stall.pos, Stall.at = hrp.Position, os.clock()
                    elseif os.clock() - Stall.at > 4 then
                        _G.RJR_BoardStall = nil
                        if _G.RJR_RecoverLock then
                            _G.RJR_RecoverLock("no avanzo al subir al asiento")
                        end
                        return false
                    end
                else
                    _G.RJR_BoardStall = nil
                end
                _tp(LiveSeatCF(seat), function()
                    if (not _G.AutoLeviathanFull) or (not seat or not seat.Parent) then
                        return true
                    end
                    local _, _, humNow = GetCharacterParts()
                    return humNow ~= nil and humNow.SeatPart ~= nil
                end)
            else
                AbandonIfTooFar(seat)
                return false
            end
        end
        task.wait(0.2)
    end
    return IsSittingOn(seat)
end
local function ForceUnseat(Seconds)
    local Deadline = os.clock() + (Seconds or 10)
    while _G.AutoLeviathanFull and os.clock() < Deadline do
        local _, _, hum = GetCharacterParts()
        if not hum or (not hum.Sit and hum.SeatPart == nil) then
            return true
        end
        Unseat()
        task.wait(0.3)
    end
    local _, _, hum = GetCharacterParts()
    return hum == nil or (not hum.Sit and hum.SeatPart == nil)
end
local function BoardSeatRetry(seat, timeout, attempts)
    attempts = attempts or 3
    for _ = 1, attempts do
        if not seat or not seat.Parent then
            return false
        end
        if BoardSeat(seat, timeout) then
            return true
        end
        Unseat()
        task.wait(0.5)
    end
    return false
end
local function DebugDumpBoats()
    local boats = workspace:FindFirstChild("Boats")
    print("=== [DEBUG] workspace.Boats al comprar ===")
    if not boats then
        print("[DEBUG] workspace.Boats no existe")
        return
    end
    local hrp = select(2, GetCharacterParts())
    for _, b in ipairs(boats:GetChildren()) do
        local Owner = b:FindFirstChild("Owner")
        local vs = b:FindFirstChild("VehicleSeat")
        local dist = (hrp and vs and (vs.Position - hrp.Position).Magnitude) or -1
        print(string.format("[DEBUG] barco=%s | claseOwner=%s | owner=%s | VehicleSeat=%s | dist=%.0f | esBeastHunter=%s",
            tostring(b.Name),
            Owner and Owner.ClassName or "nil",
            Owner and tostring(Owner.Value) or "-",
            tostring(vs ~= nil),
            dist,
            tostring(IsBeastHunterBoat(b))))
    end
end
local function BuyOwnBoat(Message)
    if OwnBoatUnusable(LocalPlayer, false) then
        SetStatus("Barco viejo inservible: espero el reinicio para recomprar")
        return false
    end
    SetStatus(Message or "El barco desapareció: vuelo a comprar otro")
    local _, _, humB = GetCharacterParts()
    if humB and (humB.Sit or humB.SeatPart ~= nil) then
        if not Unseat() then
            SetStatus("No pude bajarme antes de comprar: voy igual al vendedor")
        end
    end
    local start = os.clock()
    local Arrived = false
    while _G.AutoLeviathanFull and os.clock() - start < 90 do
        local _, hrp = GetCharacterParts()
        if hrp and (hrp.Position - BoatDealerCF.Position).Magnitude <= 20 then
            Arrived = true
            break
        end
        _tp(LiveFixedCF(BoatDealerCF), function()
            return (not _G.AutoLeviathanFull) or OwnBoatUnusable(LocalPlayer, false)
        end)
        task.wait(0.5)
    end
    if not Arrived then
        DebugDumpBoats()
        print("[DEBUG] BuyOwnBoat no llegó al vendedor de barcos", tostring(select(2, GetCharacterParts()) and select(2, GetCharacterParts()).Position or nil))
        SetStatus("No llegué al vendedor de barcos: reintentando")
        return false
    end
    local CommF2 = Leviathan_CommF()
    if CommF2 then
        pcall(function()
            CommF2:InvokeServer("BuyBoat", "Beast Hunter")
        end)
    end
    task.wait(1)
    DebugDumpBoats()
    print("[DEBUG] BuyOwnBoat llamó a BuyBoat, esperando el barco nuevo")
    return true
end
local function NearestPlayerDistance(boat)
    local _, hrp = GetCharacterParts()
    if not hrp then
        return math.huge
    end
    local Min = math.huge
    for _, p in ipairs(Players:GetPlayers()) do
        if p ~= LocalPlayer then
            local char = p.Character
            local root = char and char:FindFirstChild("HumanoidRootPart")
            if root then
                local hum = char:FindFirstChildOfClass("Humanoid")
                local OnThisBoat = hum and hum.SeatPart ~= nil and boat ~= nil and hum.SeatPart:IsDescendantOf(boat)
                if not OnThisBoat then
                    local d = (root.Position - hrp.Position).Magnitude
                    if d < Min then
                        Min = d
                    end
                end
            end
        end
    end
    return Min
end
local LastRebuyAt = 0
local function RebuyBoatAndBoard()
    LastRebuyAt = os.clock()
    if OwnBoatUnusable(LocalPlayer, false) then
        SetStatus("Barco viejo inservible: espero el reinicio para recomprar")
        return nil, nil
    end
    SetStatus("El barco desapareció: vuelo a comprar otro")
    BuyOwnBoat()
    local SpawnStart = os.clock()
    while _G.AutoLeviathanFull and os.clock() - SpawnStart < 30 do
        local b3 = GetOwnBoat()
        local s3 = b3 and b3:FindFirstChild("VehicleSeat")
        if b3 and s3 then
            if BoardSeatRetry(s3) then
                SetStatus("Barco nuevo comprado: esperando a los compañeros")
                return b3, s3
            end
        end
        task.wait(0.5)
    end
    DebugDumpBoats()
    print("[DEBUG] RebuyBoatAndBoard: no apareció barco nuevo en 30 s")
    return nil, nil
end
local LastSailAt = 0
local CruiseCheckPos = nil
local CruiseCheckAt = 0
local CruiseStalls = 0
local CruiseToB = true
local function SailBoatStream(seat, speed)
    speed = speed or _G.BoatSpeed or 150
    if not seat or not seat.Parent then
        return false
    end
    LastSailAt = os.clock()
    local _, hrp = GetCharacterParts()
    if not hrp then
        return false
    end
    local dt = RunService.Heartbeat:Wait() or (1 / 60)
    if (seat.Position or hrp.Position).Y < 0 then
        SetStatus("Barco hundido (Y<0): lo abandono y compro otro")
        pcall(function()
            if seat.Parent then
                _G.RJR_AbandonedBoats[seat.Parent] = true
                print("[Leviathan] Barco con Y<0 abandonado: " .. seat.Parent.Name)
            end
        end)
        Unseat()
        CruiseCheckPos = nil
        if _G.RespawnRebuy and _G.RJR_ResetCharacterAtTiki then
            task.spawn(_G.RJR_ResetCharacterAtTiki, "Barco hundido (Y<0)")
        end
        return false
    end
    local pos = hrp.Position
    local target = _G.CruiseReturn and (CruiseToB and CruiseWP_B or CruiseWP_A) or CruiseWP_Far
    local zone = target.Position
    local flat = Vector3.new(zone.X - pos.X, 0, zone.Z - pos.Z)
    local dist = flat.Magnitude
    if _G.CruiseReturn and dist <= SailArriveDist then
        CruiseToB = not CruiseToB
        target = CruiseToB and CruiseWP_B or CruiseWP_A
        zone = target.Position
        flat = Vector3.new(zone.X - pos.X, 0, zone.Z - pos.Z)
        dist = flat.Magnitude
    end
    if os.clock() - CruiseCheckAt >= 15 then
        if CruiseCheckPos
            and Vector3.new(pos.X - CruiseCheckPos.X, 0, pos.Z - CruiseCheckPos.Z).Magnitude < 200 then
            CruiseStalls = CruiseStalls + 1
            if CruiseStalls >= 2 then
                CruiseStalls = 0
                CruiseCheckPos = nil
                CruiseCheckAt = os.clock()
                if _G.RJR_RecoverLock then
                    _G.RJR_RecoverLock("el barco no avanza")
                end
            else
                SetStatus("Crucero atascado: bajo y vuelvo a subir para reiniciar")
                Unseat()
                task.wait(0.3)
                if seat.Parent then
                    BoardSeatRetry(seat, 10)
                end
                CruiseCheckPos = nil
            end
        else
            CruiseStalls = 0
            CruiseCheckPos = pos
        end
        CruiseCheckAt = os.clock()
    end
    local dir = flat.Unit
    local step = math.min(dist, speed * dt)
    local np = pos + dir * step
    local lockY = _G.BoatHeight or 150
    pcall(function()
        hrp.CFrame = CFrame.lookAt(Vector3.new(np.X, lockY, np.Z),
            Vector3.new(np.X, lockY, np.Z - 1), Vector3.new(0, 1, 0))
        hrp.AssemblyLinearVelocity = Vector3.zero
    end)
    return true
end
local function SailBoatTurn(seat, targetPos, speed, FixedY)
    speed = speed or _G.BoatSpeed or 250
    local pos = seat.Position
    local flat = Vector3.new(targetPos.X - pos.X, 0, targetPos.Z - pos.Z)
    if flat.Magnitude < 0.5 then
        return
    end
    LastSailAt = os.clock()
    local dt = RunService.Heartbeat:Wait() or 1 / 60
    local yaw = math.atan2(flat.X, flat.Z) + math.pi
    local move = flat.Unit * speed * dt
    local newPos = seat.Position + move
    seat.CFrame = CFrame.new(newPos.X, FixedY or seat.Position.Y, newPos.Z) * CFrame.Angles(0, yaw, 0)
end
local SeaAPI = {}
do
local Sea_MobStillAlive
local function Sea_Mob(MaxDistance, Exclude)
    MaxDistance = MaxDistance or 1500
    local Enemies = workspace:FindFirstChild("Enemies")
    local SeaBeasts = workspace:FindFirstChild("SeaBeasts")
    local MobList = {
        {Name = "Terrorshark", ConfigName = "Terrorshark", Folder = Enemies, Skill = false},
        {Name = "Piranha", ConfigName = "Piranha", Folder = Enemies, Skill = false},
        {Name = "Shark", ConfigName = "Shark", Folder = Enemies, Skill = false},
        {Name = "Fish Crew Member", ConfigName = "Fish Crew Member", Folder = Enemies, Skill = false},
        {Name = "FishBoat", ConfigName = "Ghost Ship", Folder = Enemies, Skill = true},
        {Name = "PirateBrigade", ConfigName = "Pirate Brigade Ship", Folder = Enemies, Skill = true},
        {Name = "PirateGrandBrigade", ConfigName = "Pirate Grand Brigade Ship", Folder = Enemies, Skill = true},
        {Name = "PirateBasic", ConfigName = "Pirate Basic Ship", Folder = Enemies, Skill = true},
        {Name = "SeaBeast1", ConfigName = "Sea Beast", Folder = SeaBeasts, Skill = true},
    }
    local Selected = _G.HuntSelectEvents
    local HasFilter = type(Selected) == "table" and #Selected > 0
    for _, Data in ipairs(MobList) do
        if HasFilter and not table.find(Selected, Data.ConfigName) then
        elseif Data.Folder then
            for _, Mob in ipairs(Data.Folder:GetChildren()) do
                if Mob.Name == Data.Name and not (Exclude and Exclude[Mob]) then
                    local Alive = Sea_MobStillAlive(Mob)
                    local Root = Mob:FindFirstChild("HumanoidRootPart")
                        or Mob:FindFirstChild("RootPart")
                        or Mob.PrimaryPart
                        or Mob:FindFirstChild("Head")
                        or Mob:FindFirstChildWhichIsA("BasePart", true)
                    if Alive and Root and Root.Position and HRP
                    and (Root.Position - HRP.Position).Magnitude <= MaxDistance then
                        return Mob, Root, Data.Skill == true
                    end
                end
            end
        end
    end
    return nil, nil, false
end
Sea_MobStillAlive = function(Mob)
    if not Mob or not Mob.Parent then
        return false
    end
    local Health = Mob:FindFirstChild("Health")
    if Health and Health:IsA("ValueBase") and Health.Value <= 0 then
        return false
    end
    local Humanoid = Mob:FindFirstChildOfClass("Humanoid")
    if Humanoid and Humanoid.Health <= 0 then
        return false
    end
    return (Health ~= nil and Health:IsA("ValueBase")) or (Humanoid ~= nil)
end
local FaceTargetCF = (function()
    local Cached = { model = nil, part = nil, at = 0 }
    return function(standPos, model)
        if not model or not model.Parent or model:IsA("BasePart") then
            return nil
        end
        local now = os.clock()
        if Cached.model ~= model or now - Cached.at > 2 then
            Cached.model, Cached.at, Cached.part = model, now, nil
            local best, bestDist = nil, nil
            local stack, visited = { model }, 0
            while #stack > 0 and visited < 150 do
                local node = table.remove(stack)
                for _, child in ipairs(node:GetChildren()) do
                    visited = visited + 1
                    if child:IsA("BasePart") then
                        local flat = Vector3.new(child.Position.X - standPos.X, 0, child.Position.Z - standPos.Z)
                        local d = flat.Magnitude
                        if d > 1 and (bestDist == nil or d < bestDist) then
                            best, bestDist = child, d
                        end
                    elseif child:IsA("Model") then
                        stack[#stack + 1] = child
                    end
                end
            end
            Cached.part = best
        end
        local part = Cached.part
        if not part or not part.Parent then
            return nil
        end
        local flat = Vector3.new(part.Position.X - standPos.X, 0, part.Position.Z - standPos.Z)
        if flat.Magnitude < 1 then
            return nil
        end
        return CFrame.lookAt(standPos, standPos + flat.Unit)
    end
end)()
local function Sea_Stand(Mob, Root)
    if not Root then
        return nil
    end
    local standPos
    if Mob.Parent and Mob.Parent.Name == "SeaBeasts" then
        standPos = Vector3.new(Root.Position.X, 120, Root.Position.Z)
    else
        standPos = Root.Position + Vector3.new(0, 40, 0)
    end
    return FaceTargetCF(standPos, Mob) or CFrame.new(standPos)
end
local function Sea_EventRoot(Mob)
    if not Mob then
        return nil
    end
    return Mob:FindFirstChild("HumanoidRootPart")
        or Mob:FindFirstChild("RootPart")
        or Mob.PrimaryPart
        or Mob:FindFirstChild("Head")
        or Mob:FindFirstChildWhichIsA("BasePart", true)
end
local ShootGunEvent = nil
local Validator2 = nil
local shootFunc, idx, dragonReady = nil, {}, false
local LIMB_PARTS = {
    "Head", "UpperTorso", "LowerTorso",
    "LeftUpperArm", "RightUpperArm", "LeftLowerArm", "RightLowerArm",
    "LeftUpperLeg", "RightUpperLeg", "LeftLowerLeg", "RightLowerLeg",
    "HumanoidRootPart"
}
local VALID_SEA_ENEMIES = {
    "Terrorshark", "Shark", "Piranha",
    "Fish Crew Member", "Haunted Crew Member",
    "FishBoat", "PirateBrigade", "PirateGrandBrigade"
}
local function getRandomLimb(character)
    if not character then
        return nil
    end
    local available = {}
    for _, name in ipairs(LIMB_PARTS) do
        local part = character:FindFirstChild(name)
        if part and part:IsA("BasePart") then
            available[#available + 1] = part
        end
    end
    if #available == 0 then
        return character:FindFirstChild("HumanoidRootPart")
    end
    return available[math.random(1, #available)]
end
local function initDragon()
    if dragonReady then
        return
    end
    local success = pcall(function()
        local cc = require(RS:WaitForChild("Controllers"):WaitForChild("CombatController"))
        for _, v in ipairs(debug.getupvalues(cc.Attack)) do
            if type(v) == "function" then
                for i, uv in ipairs(debug.getupvalues(v)) do
                    if uv == 727595 then
                        shootFunc = v
                        idx = { u25 = i - 3, u21 = i - 2, u24 = i - 1, u20 = i, u22 = i + 1, u23 = i + 2, u26 = i + 3 }
                        break
                    end
                end
                if shootFunc then
                    break
                end
            end
        end
    end)
    if success and shootFunc then
        dragonReady = true
    end
end
local function fireShot(pos, hit)
    if not shootFunc or not Validator2 or not ShootGunEvent then
        return
    end
    local u20 = debug.getupvalue(shootFunc, idx.u20)
    local u21 = debug.getupvalue(shootFunc, idx.u21)
    local u22 = debug.getupvalue(shootFunc, idx.u22)
    local u23 = debug.getupvalue(shootFunc, idx.u23)
    local u24 = debug.getupvalue(shootFunc, idx.u24)
    local u25 = debug.getupvalue(shootFunc, idx.u25)
    local u26 = debug.getupvalue(shootFunc, idx.u26)
    local u79 = u25 * u21
    local u80 = (u24 * u21 + u25 * u20) % u22
    u80 = (u80 * u22 + u79) % u23
    u24 = math.floor(u80 / u22)
    u25 = u80 - u24 * u22
    u26 = u26 + 1
    debug.setupvalue(shootFunc, idx.u24, u24)
    debug.setupvalue(shootFunc, idx.u25, u25)
    debug.setupvalue(shootFunc, idx.u26, u26)
    Validator2:FireServer(math.floor(u80 / u23 * 16777215), u26)
    ShootGunEvent:FireServer(pos, { hit })
end
local SeaBoatModelsCache, SeaBoatModelsAt
local function getAllPlayerBoatModels()
    local now = os.clock()
    if SeaBoatModelsCache and (now - SeaBoatModelsAt) < 0.5 then
        return SeaBoatModelsCache
    end
    local models = {}
    local boats = workspace:FindFirstChild("Boats")
    if boats then
        for _, v in ipairs(boats:GetChildren()) do
            local owner = v:FindFirstChild("Owner")
            if owner and owner.Value and tostring(owner.Value) ~= "" then
                models[v.Name] = true
            end
        end
    end
    SeaBoatModelsCache, SeaBoatModelsAt = models, now
    return models
end
local AttackRange = 450
local SeaTargetCache, SeaTargetAt
local function getClosestSeaTarget()
    local now = os.clock()
    if SeaTargetCache and (now - SeaTargetAt) < 0.2 then
        return SeaTargetCache
    end
    local char = LocalPlayer.Character
    if not char then
        return nil
    end
    local myHRP = char:FindFirstChild("HumanoidRootPart")
    if not myHRP then
        return nil
    end
    local best, bestDist = nil, AttackRange
    local playerBoats = getAllPlayerBoatModels()
    local seaBeasts = workspace:FindFirstChild("SeaBeasts")
    if seaBeasts then
        for _, e in ipairs(seaBeasts:GetChildren()) do
            local hrp = e:FindFirstChild("HumanoidRootPart")
            local hp = e:FindFirstChild("Health")
            if hrp and hp and hp:IsA("ValueBase") and hp.Value > 0 then
                local segment = e:FindFirstChild("Leviathan Segment")
                if segment then
                    local dist = (segment.Position - myHRP.Position).Magnitude
                    if dist < bestDist then
                        bestDist = dist
                        best = segment
                    end
                end
                local dist = (hrp.Position - myHRP.Position).Magnitude
                if dist < bestDist then
                    bestDist = dist
                    best = getRandomLimb(e) or hrp
                end
            end
        end
    end
    local enemies = workspace:FindFirstChild("Enemies")
    if enemies then
        for _, e in ipairs(enemies:GetChildren()) do
            if table.find(VALID_SEA_ENEMIES, e.Name) and not playerBoats[e.Name] then
                local engine = e:FindFirstChild("Engine")
                local isBoat = engine and e:FindFirstChild("VehicleSeat")
                if isBoat then
                    local hp = e:FindFirstChild("Health")
                    if hp and hp:IsA("ValueBase") and hp.Value > 0 then
                        local dist = (engine.Position - myHRP.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            best = engine
                        end
                    end
                else
                    local hrp = e:FindFirstChild("HumanoidRootPart")
                    local hum = e:FindFirstChildOfClass("Humanoid")
                    if hrp and hum and hum.Health > 0 then
                        local dist = (hrp.Position - myHRP.Position).Magnitude
                        if dist < bestDist then
                            bestDist = dist
                            best = getRandomLimb(e) or hrp
                        end
                    end
                end
            end
        end
    end
    SeaTargetCache, SeaTargetAt = best, now
    return best
end
local function StartDragonAttack()
    task.spawn(function()
        while not dragonReady do
            initDragon()
            task.wait(1)
        end
        print("[Dragonstorm] listo")
        while _G.DragonGunFarm do
            pcall(function()
                if not ShootGunEvent then
                    local modules = RS:FindFirstChild("Modules")
                    local net = modules and modules:FindFirstChild("Net")
                    ShootGunEvent = net and net:FindFirstChild("RE/ShootGunEvent")
                end
                if not Validator2 then
                    local remotes = RS:FindFirstChild("Remotes")
                    Validator2 = remotes and remotes:FindFirstChild("Validator2")
                end
                if not ShootGunEvent or not Validator2 then
                    return
                end
                local target = getClosestSeaTarget()
                if not target then
                    return
                end
                local char = LocalPlayer.Character
                if not char then
                    return
                end
                local tool = char:FindFirstChildOfClass("Tool")
                if not tool or tool.Name ~= "Dragonstorm" then
                    if not IsOnBoat() then
                        Equip_Auto("Dragonstorm")
                    end
                    return
                end
                fireShot(target.Position, target)
            end)
            task.wait()
        end
    end)
end
local function FightSeaEvent(Mob, Root, Skill, ShouldBreak)
    local start = os.clock()
    local function CurrentStand()
        local r = Sea_EventRoot(Mob)
        if not r then
            return nil
        end
        return Sea_Stand(Mob, r)
    end
    while _G.AutoLeviathanFull and os.clock() - start < 600 do
        if ShouldBreak and ShouldBreak() then
            SetStatus("El capitán volvió al barco: dejo de pelear y vuelvo")
            break
        end
        if not Character or not HRP or not HD or HD.Health <= 0 then
            break
        end
        if not Mob or not Mob.Parent or not Sea_MobStillAlive(Mob) then
            if Mob then
                SetStatus("Evento marino derrotado: " .. Mob.Name)
            end
            break
        end
        SetStatus("Farmeo marino: " .. Mob.Name .. " (llevo " .. math.floor(os.clock() - start) .. " s)")
        AttackModel = Mob
        AttackStandFn = CurrentStand
        local _, _, humSE = GetCharacterParts()
        if humSE and (humSE.Sit or humSE.SeatPart ~= nil) then
            SetStatus("Farmeo marino: comprobando salir del asiento")
            ForceUnseat(5)
        end
        local Stand = CurrentStand()
        if Stand then
            local _, hrpNow = GetCharacterParts()
            if hrpNow and (Stand.Position - hrpNow.Position).Magnitude > 10 then
                _tp(CurrentStand, function()
                    return (not _G.AutoLeviathanFull) or (not Mob or not Mob.Parent)
                        or (not Sea_MobStillAlive(Mob)) or (ShouldBreak and ShouldBreak())
                end)
            end
            if not Sea_MobStillAlive(Mob) then
                SetStatus("Evento marino derrotado: " .. Mob.Name)
                break
            end
            FightTarget = { CF = Stand, At = os.clock() }
        end
        if not IsOnBoat() then
            if _G.DragonGunFarm then
                Equip_Auto("Dragonstorm")
            elseif Stand and HRP then
                local Distance = (Stand.Position - HRP.Position).Magnitude
                local RootNow = Sea_EventRoot(Mob)
                local MobUp = (RootNow and RootNow.Position and RootNow.Position.Y or 0) >= -600
                if Skill and Distance <= 80 and MobUp then
                    pcall(CoolDown_Auto)
                else
                    Equip_Auto(_G.SelectWeapon or "Sword")
                end
            end
        end
        Haki_Auto()
        task.wait(0.05)
    end
    AttackModel = nil
    AttackStandFn = nil
    FightTarget = nil
    task.wait(0.3)
end
local function Leviathan_IsDead(model)
    local Hum = model:FindFirstChildOfClass("Humanoid")
    if Hum and Hum.Health <= 0 then
        return true
    end
    local Health = model:FindFirstChild("Health")
    if Health and (Health:IsA("NumberValue") or Health:IsA("IntValue")) and Health.Value <= 0 then
        return true
    end
    return false
end
local function Leviathan_GetHP(model)
    if not model then
        return nil
    end
    local Hum = model:FindFirstChildOfClass("Humanoid")
    if Hum then
        return Hum.Health
    end
    local Health = model:FindFirstChild("Health")
    if Health and (Health:IsA("NumberValue") or Health:IsA("IntValue")) then
        return Health.Value
    end
    return nil
end
local function Leviathan_RootPart(model)
    if not model then
        return nil
    end
    return model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("RootPart")
        or model.PrimaryPart
        or model:FindFirstChildWhichIsA("BasePart")
end
local LeviathanFindCache
local LeviathanFindCacheAt = 0
local function Leviathan_Find()
    local now = os.clock()
    if LeviathanFindCache and (now - LeviathanFindCacheAt) < 0.25 then
        return LeviathanFindCache[1], LeviathanFindCache[2]
    end
    local SeaBeasts = workspace:FindFirstChild("SeaBeasts")
    if not SeaBeasts then
        LeviathanFindCache, LeviathanFindCacheAt = nil, now
        return nil, nil
    end
    local foundModel, foundPart = nil, nil
    for _, model in ipairs(SeaBeasts:GetChildren()) do
        if model.Name == "Leviathan Segment" and not Leviathan_IsDead(model) then
            local part = Leviathan_RootPart(model)
            if part then
                foundModel, foundPart = model, part
                break
            end
        end
    end
    if not foundModel then
        local leviathan = SeaBeasts:FindFirstChild("Leviathan")
        if leviathan then
            local part = Leviathan_RootPart(leviathan)
            if part and not Leviathan_IsDead(leviathan) then
                foundModel, foundPart = leviathan, part
            end
        end
    end
    LeviathanFindCache, LeviathanFindCacheAt = {foundModel, foundPart}, now
    return foundModel, foundPart
end
local function Leviathan_SegmentsExist()
    return Leviathan_Find() ~= nil
end
local function Leviathan_Stand(model, part)
    local Root = model:FindFirstChild("HumanoidRootPart")
        or model:FindFirstChild("RootPart")
        or model.PrimaryPart
        or model:FindFirstChild("Head")
        or part
    if not Root then
        return nil
    end
    local standPos = Vector3.new(Root.Position.X, Root.Position.Y + 75, Root.Position.Z)
    return FaceTargetCF(standPos, model) or CFrame.new(standPos)
end
local LeviathanWaitDone = false
task.spawn(function()
    local LastSeenAt = os.clock()
    while true do
        task.wait(0.5)
        if Leviathan_Find() then
            LastSeenAt = os.clock()
        elseif os.clock() - LastSeenAt > 15 then
            LeviathanWaitDone = false
        end
    end
end)
local function FightLeviathan(ShouldBreak, WaitSec)
    local model, part = Leviathan_Find()
    if not model then
        return false
    end
    if not LeviathanWaitDone then
        WaitSec = WaitSec or 10
        local WaitStart = os.clock()
        local Completed = true
        while _G.AutoLeviathanFull and os.clock() - WaitStart < WaitSec do
            if ShouldBreak and ShouldBreak() then
                Completed = false
                break
            end
            if not Leviathan_Find() then
                Completed = false
                break
            end
            SetStatus("El Leviathan apareció: ataco en " .. string.format("%.1f", WaitSec - (os.clock() - WaitStart)) .. " s")
            task.wait(0.2)
        end
        LeviathanWaitDone = Completed
    end
    local Killed = false
    local start = os.clock()
    local LastFind = 0
    local MissingSince = nil
    local MissingGrace = 15
    while _G.AutoLeviathanFull and os.clock() - start < 900 do
        if ShouldBreak and ShouldBreak() then
            break
        end
        if not Character or not HRP or not HD or HD.Health <= 0 then
            break
        end
        local _, _, humNow = GetCharacterParts()
        if humNow and (humNow.Sit or humNow.SeatPart ~= nil) then
            SetStatus("Pelea a pie: comprobando salir del asiento")
            if not ForceUnseat(20) then
                SetStatus("No consigo bajarme: salgo de este combate")
                break
            end
        end
        if os.clock() - LastFind >= 0.4 then
            LastFind = os.clock()
            model, part = Leviathan_Find()
            if model then
                MissingSince = nil
                if Leviathan_IsDead(model) then
                    Killed = true
                    break
                end
            else
                MissingSince = MissingSince or os.clock()
                if os.clock() - MissingSince >= MissingGrace then
                    Killed = true
                    break
                end
            end
        end
        if not model then
            SetStatus("Leviathan no encontrado por ahora: sigo esperando")
            AttackModel = nil
            AttackStandFn = nil
            FightTarget = nil
            task.wait(0.2)
        else
            local MyHP = HD and HD.Health
            if MyHP and MyHP < 3000 then
                SetStatus("Vida baja: subo a evadir (" .. string.format("%.0f", MyHP) .. ")")
                local _, hrp = GetCharacterParts()
                local FleeY = hrp and (hrp.Position.Y + 1050) or nil
                local EscStart = os.clock()
                while _G.AutoLeviathanFull and os.clock() - EscStart < 600 do
                    if ShouldBreak and ShouldBreak() then
                        break
                    end
                    if not Character or not HRP or not HD or HD.Health <= 0 then
                        break
                    end
                    model, part = Leviathan_Find()
                    if not model then
                        break
                    end
                    local H = HD and HD.Health
                    if H and H >= 5000 then
                        SetStatus("Vida recuperada: sigo atacando")
                        break
                    end
                    local _, hrp2 = GetCharacterParts()
                    local _, _, hum2 = GetCharacterParts()
                    if hum2 and (hum2.Sit or hum2.SeatPart ~= nil) then
                        pcall(function()
                            hum2.Sit = false
                            hum2.PlatformStand = false
                        end)
                    end
                    if hrp2 and FleeY then
                        hrp2.CFrame = CFrame.new(hrp2.Position.X, FleeY, hrp2.Position.Z)
                    end
                    task.wait(0.2)
                end
                task.wait(0.5)
            end
            if model then
                local _, _, humPre = GetCharacterParts()
                if humPre and (humPre.Sit or humPre.SeatPart ~= nil) then
                    SetStatus("Sigo sentado antes de atacar: me bajo a la fuerza")
                    ForceUnseat(5)
                end
                local HPNow = Leviathan_GetHP(model)
                SetStatus("Atacando al Leviathan: " .. model.Name .. (HPNow and (" - vida " .. string.format("%.0f", HPNow)) or ""))
                local function CurrentStand()
                    if not model.Parent or Leviathan_IsDead(model) then
                        return nil
                    end
                    local _, p = Leviathan_Find()
                    return Leviathan_Stand(model, p or part)
                end
                AttackModel = model
                AttackStandFn = CurrentStand
                local Stand = CurrentStand()
                if Stand then
                    local _, hrpNow = GetCharacterParts()
                    if not hrpNow or (Stand.Position - hrpNow.Position).Magnitude > 10 then
                        _tp(CurrentStand, function()
                            return (not _G.AutoLeviathanFull) or (not model or not model.Parent)
                                or (ShouldBreak and ShouldBreak())
                        end)
                    end
                    FightTarget = { CF = Stand, At = os.clock() }
                end
                if _G.DragonGunLeviathan and CheckItem("Dragonstorm") then
                    initDragon()
                    Equip_Auto("Dragonstorm")
                    local target = getClosestSeaTarget()
                    if target then
                        fireShot(target.Position, target)
                    end
                else
                    local Distance = Stand and (Stand.Position - HRP.Position).Magnitude or 0
                    if Distance <= 80 then
                        pcall(CoolDown_Auto)
                    else
                        Equip_Auto(_G.SelectWeapon or "Sword")
                    end
                end
                Haki_Auto()
            end
        end
        task.wait(0.05)
    end
    AttackModel = nil
    AttackStandFn = nil
    FightTarget = nil
    return Killed
end
SeaAPI.Sea_Mob = Sea_Mob
SeaAPI.Sea_MobStillAlive = Sea_MobStillAlive
SeaAPI.Sea_Stand = Sea_Stand
SeaAPI.StartDragonAttack = StartDragonAttack
SeaAPI.InitDragon = initDragon
SeaAPI.FightSeaEvent = FightSeaEvent
SeaAPI.Leviathan_IsDead = Leviathan_IsDead
SeaAPI.Leviathan_GetHP = Leviathan_GetHP
SeaAPI.Leviathan_Find = Leviathan_Find
SeaAPI.Leviathan_SegmentsExist = Leviathan_SegmentsExist
SeaAPI.Leviathan_Stand = Leviathan_Stand
SeaAPI.FightLeviathan = FightLeviathan
end
_G.RJR_BoatDeadArmed = true
_G.RJR_BoatDeadMonitorRunning = false
_G.RJR_Resetting = false
_G.RJR_LeviathanPresent = function()
    local MapL = workspace:FindFirstChild("Map")
    if not MapL then
        return SeaAPI.Leviathan_SegmentsExist()
    end
    if MapL:FindFirstChild("LeviathanGate") or MapL:FindFirstChild("FrozenHeart") then
        return true
    end
    return SeaAPI.Leviathan_SegmentsExist()
end
_G.RJR_ResetCharacterAtTiki = function(reason)
    if _G.RJR_Resetting then
        return
    end
    if _G.RJR_LeviathanPresent() then
        SetStatus("Leviathan, puerta o corazón presentes: no reinicio")
        return
    end
    _G.RJR_Resetting = true
    local WaitStart = os.clock()
    while _G.AutoLeviathanFull and os.clock() - WaitStart < 120 do
        local M = select(1, SeaAPI.Sea_Mob(1200))
        if not M then
            break
        end
        SetStatus(reason .. ": esperando a terminar el evento marino")
        task.wait(1)
    end
    if _G.RJR_LeviathanPresent() then
        SetStatus("Leviathan, puerta o corazón presentes: no reinicio")
        _G.RJR_Resetting = false
        return
    end
    SetStatus(reason .. ": reiniciando en Tiki para comprar barco")
    pcall(Unseat)
    pcall(function()
        local CommF2 = Leviathan_CommF()
        if CommF2 then
            CommF2:InvokeServer("SetLastSpawnPoint", "Tiki")
        end
    end)
    local _, _, hum = GetCharacterParts()
    if hum and hum.Health > 0 then
        pcall(function()
            hum.Health = 0
        end)
    end
    local Deadline = os.clock() + 20
    while os.clock() < Deadline do
        local _, h, hm = GetCharacterParts()
        if h and hm and hm.Health > 0 then
            break
        end
        task.wait(0.2)
    end
    for _, boat in ipairs(OwnedBoatsOf(LocalPlayer)) do
        _G.RJR_AbandonedBoats[boat] = true
        print("[Leviathan] Reinicio hecho, barco viejo abandonado: " .. boat.Name)
    end
    _G.RJR_Resetting = false
end
_G.RJR_StartBoatDeadMonitor = function()
    if _G.RJR_BoatDeadMonitorRunning then
        return
    end
    _G.RJR_BoatDeadMonitorRunning = true
    task.spawn(function()
        local StartAt = os.clock()
        local SawRealBoat = false
        local BoatGoneSince = nil
        local LastResetAt = 0
        local SawCaptainAlive = false
        local CaptainDied = false
        local CaptainDeathAt = 0
        local CaptainDeathFollowed = false
        local CaptainDeathReason = "Capitán muerto"
        while _G.AutoLeviathanFull do
            if _G.RespawnRebuy then
                local isCaptain = _G.Mode == "Capitán"
                local target = isCaptain and LocalPlayer or Players:FindFirstChild(_G.FollowTarget)
                local Trigger = nil
                local _, _, humSelf = GetCharacterParts()
                local SelfAlive = humSelf ~= nil and humSelf.Health > 0
                local Gone = false
                if target then
                    local Boats = OwnedBoatsOf(target)
                    if #Boats > 0 then
                        SawRealBoat = true
                        BoatGoneSince = nil
                    elseif SawRealBoat then
                        Gone = true
                    end
                    if Gone and (isCaptain or _G.RJR_Resetting or not SelfAlive) then
                        Gone = false
                    end
                    if Gone then
                        BoatGoneSince = BoatGoneSince or os.clock()
                        if os.clock() - BoatGoneSince >= 10 then
                            Trigger = "Barco del capitán desaparecido"
                        end
                    end
                    if not Trigger and OwnBoatUnusable(target, not isCaptain) then
                        Trigger = isCaptain and "Barco destruido (vida 0)" or "Barco del capitán inservible"
                    end
                    if not isCaptain then
                        local CChar = target.Character
                        local CHum = CChar and CChar:FindFirstChildOfClass("Humanoid")
                        if CHum then
                            if CHum.Health > 0 then
                                SawCaptainAlive = true
                                CaptainDied = false
                                CaptainDeathFollowed = false
                            elseif SawCaptainAlive and not CaptainDied then
                                CaptainDied = true
                                CaptainDeathAt = os.clock()
                            end
                        end
                        if CaptainDied and not SelfAlive then
                            CaptainDeathFollowed = true
                        end
                        if CaptainDied and not CaptainDeathFollowed and not Trigger
                            and os.clock() - CaptainDeathAt >= 1.5
                            and not _G.RJR_Resetting then
                            Trigger = CaptainDeathReason
                        end
                    end
                end
                if Trigger and _G.RJR_LeviathanPresent and _G.RJR_LeviathanPresent() then
                    Trigger = nil
                end
                if Trigger then
                    if _G.RJR_BoatDeadArmed and os.clock() - StartAt > 8 then
                        _G.RJR_BoatDeadArmed = false
                        LastResetAt = os.clock()
                        SawRealBoat = false
                        BoatGoneSince = nil
                        if Trigger == CaptainDeathReason then
                            CaptainDeathFollowed = true
                        end
                        task.spawn(_G.RJR_ResetCharacterAtTiki, Trigger)
                    elseif not _G.RJR_BoatDeadArmed and os.clock() - LastResetAt > 120 then
                        _G.RJR_BoatDeadArmed = true
                    end
                else
                    _G.RJR_BoatDeadArmed = true
                end
            else
                SawRealBoat = false
                BoatGoneSince = nil
            end
            task.wait(0.5)
        end
        _G.RJR_BoatDeadMonitorRunning = false
    end)
end
do
local RecoverLock = { running = false, tries = 0, since = 0 }
local function RecoverPositionLock(reason)
    if RecoverLock.running or not _G.AutoLeviathanFull then
        return
    end
    if os.clock() - (RecoverLock.lastAt or 0) < 30 then
        return
    end
    RecoverLock.lastAt = os.clock()
    RecoverLock.running = true
    task.spawn(function()
        local ok = pcall(function()
        local _, _, humNow = GetCharacterParts()
        local Phantom = humNow ~= nil and humNow.SeatPart ~= nil
            and not _G.RJR_SeatConfirmed(humNow.SeatPart)
        if os.clock() - RecoverLock.since > 180 then
            RecoverLock.tries = 0
            RecoverLock.since = os.clock()
        end
        if Phantom then
            RecoverLock.tries = RecoverLock.tries + 1
        end
        SetStatus("Personaje bloqueado en el sitio (" .. tostring(reason or "?") .. "): lo libero")
        pcall(function()
            local _, _, hum = GetCharacterParts()
            _G.RJR_BreakPhantomSeat(hum and hum.SeatPart or nil)
        end)
        pcall(Unseat)
        local FreedAt = os.clock() + 3
        local Freed = false
        while os.clock() < FreedAt do
            local _, _, hum = GetCharacterParts()
            if not hum then
                Freed = true
                break
            end
            if not hum.Sit and hum.SeatPart == nil then
                Freed = true
                break
            end
            task.wait(0.2)
        end
        if ((not Freed) or RecoverLock.tries >= 2) and _G.AutoLeviathanFull and not _G.RJR_Resetting then
            if _G.RJR_LeviathanPresent and _G.RJR_LeviathanPresent() then
                SetStatus("Sigo bloqueado, pero hay Leviathan/puerta/corazón: no reinicio")
            elseif os.clock() - (RecoverLock.lastResetAt or 0) < 180 then
                SetStatus("Sigo bloqueado: espero antes de volver a reiniciar")
            elseif _G.RJR_ResetCharacterAtTiki then
                RecoverLock.tries = 0
                RecoverLock.since = os.clock()
                RecoverLock.lastResetAt = os.clock()
                SetStatus("Sigo bloqueado: reinicio el personaje en Tiki")
                pcall(_G.RJR_ResetCharacterAtTiki, "Personaje bloqueado")
            end
        end
        end)
        if not ok then
            print("[Leviathan] RecoverPositionLock: error, se libera el flag")
        end
        RecoverLock.running = false
    end)
end
_G.RJR_RecoverLock = RecoverPositionLock
task.spawn(function()
    local LastPos, StuckCount, LastRecover = nil, 0, 0
    while true do
        task.wait(1)
        local _, hrp, hum = GetCharacterParts()
        if not _G.AutoLeviathanFull or not hrp or not hum then
            LastPos, StuckCount = nil, 0
        else
            local seat = hum.SeatPart
            local Suspicious = false
            local Distance = nil
            if seat and seat.Parent then
                Distance = (hrp.Position - seat.Position).Magnitude
                Suspicious = not _G.RJR_SeatConfirmed(seat)
            elseif hum.Sit then
                Suspicious = true
            end
            if Suspicious then
                if LastPos and (hrp.Position - LastPos).Magnitude < 8 then
                    StuckCount = StuckCount + 1
                else
                    StuckCount = 0
                end
                if StuckCount >= 2 and os.clock() - LastRecover > 30 then
                    LastRecover = os.clock()
                    StuckCount = 0
                    RecoverPositionLock(Distance and ("distancia al asiento " .. math.floor(Distance)) or "sentado sin asiento")
                end
            else
                StuckCount = 0
            end
            LastPos = hrp.Position
        end
    end
end)
end
local function ComputeHarpoonPitch(FromPos, ToPos)
    local dx = ToPos.X - FromPos.X
    local dy = ToPos.Y - FromPos.Y
    local dz = ToPos.Z - FromPos.Z
    local Horizontal = math.sqrt(dx * dx + dz * dz)
    return math.atan2(dy, Horizontal)
end
local function HarpoonHeart()
    local boat = GetOwnBoat()
    if not boat then
        return false
    end
    local DriverSeat = boat:FindFirstChild("VehicleSeat")
    if not DriverSeat then
        return false
    end
    local Map = workspace:FindFirstChild("Map")
    local Heart = Map and Map:FindFirstChild("FrozenHeart")
    local HeartPos = GetHeartPos(Heart)
    if not HeartPos then
        SetStatus("Enganche fallido: no hay corazón")
        return false
    end
    if HeartPos.Y < 110 then
        SetStatus("Corazón enganchado (Y=" .. string.format("%.0f", HeartPos.Y) .. ")")
        return true
    end
    local Harpoon = boat:FindFirstChild("Harpoon")
    local HarpoonSeat = Harpoon and Harpoon:FindFirstChild("Seat")
    if not HarpoonSeat then
        SetStatus("Enganche fallido: el barco no tiene asiento de arpón")
        return false
    end
    local BoatStartY = DriverSeat.Position.Y
    local function AimYaw(flat)
        return math.atan2(flat.X, flat.Z) + math.pi
    end
    local CommF2 = Leviathan_CommF()
    local Fires = 0
    while _G.AutoLeviathanFull and Fires < 10 do
        local Map2 = workspace:FindFirstChild("Map")
        local CurrentHeart = Map2 and Map2:FindFirstChild("FrozenHeart")
        local CurrentHeartPos = GetHeartPos(CurrentHeart)
        if not CurrentHeart or not CurrentHeartPos then
            break
        end
        if CurrentHeartPos.Y < 110 then
            SetStatus("Corazón enganchado (Y=" .. string.format("%.0f", CurrentHeartPos.Y) .. ")")
            break
        end
        SetStatus("Enganche: subo al timón (intento " .. Fires + 1 .. ")")
        if not BoardSeatRetry(DriverSeat) then
            break
        end
        SetStatus("Enganche: navego a X+300 del corazón (intento " .. Fires + 1 .. ")")
        local ApproachStart = os.clock()
        while _G.AutoLeviathanFull and os.clock() - ApproachStart < 60 do
            if not DriverSeat or not DriverSeat.Parent then
                break
            end
            local HeartNow = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("FrozenHeart")
            local HeartPosNow = HeartNow and GetHeartPos(HeartNow)
            if not HeartPosNow then
                break
            end
            local pos = DriverSeat.Position
            local TargetPoint = Vector3.new(HeartPosNow.X + 300, BoatStartY, HeartPosNow.Z)
            local flat = Vector3.new(TargetPoint.X - pos.X, 0, TargetPoint.Z - pos.Z)
            local dist = flat.Magnitude
            SetStatus("Enganche: navegando a X+300 del corazón (dist " .. math.floor(dist) .. ")")
            if dist < 10 then
                break
            end
            SailBoatTurn(DriverSeat, TargetPoint, _G.BoatSpeed, BoatStartY)
            if not IsSittingOn(DriverSeat) then
                break
            end
        end
        if not IsSittingOn(DriverSeat) then
            SetStatus("Enganche: no estoy en el timón, salto esta ronda")
            break
        end
        SetStatus("Enganche: apunto la proa al corazón (intento " .. Fires + 1 .. ")")
        local AdjustStart = os.clock()
        while _G.AutoLeviathanFull and os.clock() - AdjustStart < 15 do
            if not DriverSeat or not DriverSeat.Parent then
                break
            end
            if not IsSittingOn(DriverSeat) then
                SetStatus("Enganche: me caí del asiento, dejo de girar")
                break
            end
            local HeartNow = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("FrozenHeart")
            local HeartPosNow = HeartNow and GetHeartPos(HeartNow)
            if not HeartPosNow then
                break
            end
            local pos = DriverSeat.Position
            local flat = Vector3.new(HeartPosNow.X - pos.X, 0, HeartPosNow.Z - pos.Z)
            if flat.Magnitude < 0.5 then
                break
            end
            DriverSeat.CFrame = CFrame.new(pos.X, BoatStartY, pos.Z) * CFrame.Angles(0, AimYaw(flat), 0)
            local dir = flat.Unit
            local look = DriverSeat.CFrame.LookVector
            local dot = math.clamp(look.X * dir.X + look.Z * dir.Z, -1, 1)
            if math.acos(dot) <= 0.02 then
                break
            end
            task.wait()
        end
        SetStatus("Enganche: bajo al asiento del arpón (intento " .. Fires + 1 .. ")")
        if not Unseat() then
            SetStatus("Enganche fallido: no pude bajarme, salto la ronda")
            break
        end
        task.wait(0.3)
        if not BoardSeatRetry(HarpoonSeat) then
            SetStatus("Enganche fallido: no pude subir al asiento del arpón")
            break
        end
        local YKeepStart = os.clock()
        while _G.AutoLeviathanFull and os.clock() - YKeepStart < 3 do
            if DriverSeat and DriverSeat.Parent then
                local pos = DriverSeat.Position
                if math.abs(pos.Y - BoatStartY) > 5 then
                    DriverSeat.CFrame = CFrame.new(pos.X, BoatStartY, pos.Z) * (DriverSeat.CFrame - DriverSeat.CFrame.Position)
                end
            end
            task.wait(0.2)
        end
        local FireOrigin = Harpoon:FindFirstChild("Muzzle")
            or Harpoon:FindFirstChild("Tip")
            or Harpoon.PrimaryPart
            or HarpoonSeat
        local HeartAtFire = workspace:FindFirstChild("Map") and workspace.Map:FindFirstChild("FrozenHeart")
        local HeartPosAtFire = HeartAtFire and GetHeartPos(HeartAtFire)
        local Pitch = (FireOrigin and HeartPosAtFire)
            and (ComputeHarpoonPitch(FireOrigin.Position, HeartPosAtFire) + math.rad(3))
            or 0.7853981633974483
        if CommF2 then
            SetStatus("Enganche: disparo el arpón nº " .. Fires + 1 .. " (ángulo " .. string.format("%.1f", math.deg(Pitch)) .. "°)")
            pcall(function()
                CommF2:InvokeServer("FireHarpoon", Pitch, 0, Harpoon, workspace:GetServerTimeNow())
            end)
        end
        Fires = Fires + 1
        local GrabbedNow = false
        local PostWaitStart = os.clock()
        while _G.AutoLeviathanFull and os.clock() - PostWaitStart < 10 do
            if DriverSeat and DriverSeat.Parent then
                local pos2 = DriverSeat.Position
                if math.abs(pos2.Y - BoatStartY) > 5 then
                    DriverSeat.CFrame = CFrame.new(pos2.X, BoatStartY, pos2.Z) * (DriverSeat.CFrame - DriverSeat.CFrame.Position)
                end
            end
            local Map3 = workspace:FindFirstChild("Map")
            local Heart3 = Map3 and Map3:FindFirstChild("FrozenHeart")
            local HeartPos3 = Heart3 and GetHeartPos(Heart3)
            if not Heart3 or not HeartPos3 then
                SetStatus("Enganche: el corazón desapareció")
                break
            end
            if HeartPos3.Y < 110 then
                SetStatus("Corazón enganchado (Y=" .. string.format("%.0f", HeartPos3.Y) .. ")")
                GrabbedNow = true
                break
            end
            SetStatus("Enganche: espero el resultado (disparo " .. Fires .. ", esperando " .. math.floor(os.clock() - PostWaitStart) .. " s)")
            task.wait(0.5)
        end
        if GrabbedNow then
            break
        end
        SetStatus("Enganche fallido: bajo del arpón para reintentar")
        if not Unseat() then
            SetStatus("No pude bajar del arpón: intento la siguiente ronda")
        end
        task.wait(0.3)
    end
    Unseat()
    local MapFinal = workspace:FindFirstChild("Map")
    local HeartFinal = MapFinal and MapFinal:FindFirstChild("FrozenHeart")
    local HeartPosFinal = HeartFinal and GetHeartPos(HeartFinal)
    if HeartPosFinal and HeartPosFinal.Y < 110 then
        SetStatus("¡Corazón enganchado!")
        return true
    end
    SetStatus("Fallo: el corazón no quedó enganchado")
    return false
end
local function RestorePlayerState()
    ClearHover()
    pcall(function()
        if RestoreWallClip then
            RestoreWallClip()
        end
    end)
end
local function OpenLeviathanGate()
    local Map = workspace:FindFirstChild("Map")
    local Gate = Map and Map:FindFirstChild("LeviathanGate")
    local Watcher = Gate and Gate:FindFirstChild("FrozenWatcherPart")
    if not Watcher then
        return false
    end
    local WatcherPos = TargetPos(Watcher)
    if not WatcherPos then
        return false
    end
    _tp(LiveGateCF(5), function()
        return (not _G.AutoLeviathanFull) or SeaAPI.Leviathan_SegmentsExist()
    end)
    RestorePlayerState()
    SetStatus("En la puerta del Leviathan: esperando a que aparezca")
    local ArriveStart = os.clock()
    while _G.AutoLeviathanFull and os.clock() - ArriveStart < 60 do
        if SeaAPI.Leviathan_SegmentsExist() then
            SetStatus("Leviathan apareció: empiezo el combate")
            return true
        end
        local _, hrpA = GetCharacterParts()
        if hrpA and (hrpA.Position - WatcherPos).Magnitude < 150 then
            break
        end
        task.wait(0.5)
    end
    local CommF2 = Leviathan_CommF()
    local start = os.clock()
    local Fires = 0
    local LastInvoke = 0
    while _G.AutoLeviathanFull and os.clock() - start < 300 do
        if SeaAPI.Leviathan_SegmentsExist() then
            SetStatus("Leviathan apareció: empiezo el combate")
            return true
        end
        if CommF2 and os.clock() - LastInvoke >= 10 then
            LastInvoke = os.clock()
            Fires = Fires + 1
            SetStatus("Abriendo la puerta del Leviathan (intento " .. Fires .. ", cada 10 s)")
            pcall(function()
                CommF2:InvokeServer("OpenLeviathanGate")
            end)
        end
        task.wait(1)
    end
    return SeaAPI.Leviathan_SegmentsExist()
end
local TikiWaypointCF = CFrame.new(-2044.52, 27.82, -701.59)
local TikiReturnCF = CFrame.new(-16206.9014, 7.75799561, 404.552002)
local function ComputeSteerAngle(seat, targetPos)
    local cframe = seat.CFrame
    local look = (cframe.LookVector * Vector3.new(1, 0, 1)).Unit
    local toTarget = ((targetPos - cframe.Position) * Vector3.new(1, 0, 1)).Unit
    local angle = math.deg(math.acos(math.clamp(look:Dot(toTarget), -1, 1)))
    if look:Cross(toTarget).Y < 0 then angle = -angle end
    return angle
end
local function TurnBoatTowards(seat, targetPos)
    local pos = seat.Position
    seat.CFrame = CFrame.lookAt(pos, Vector3.new(targetPos.X, pos.Y, targetPos.Z))
end
local function TurnBoatPrimTowards(prim, targetPos)
    local pos = prim.Position
    prim.CFrame = CFrame.lookAt(pos, Vector3.new(targetPos.X, pos.Y, targetPos.Z))
end
local function SailToCF(seat, TargetCF, Speed, HeartCheck)
    Speed = Speed or _G.BoatSpeed or 250
    local TargetPos = TargetCF.Position
    local boat = (seat and seat.Parent and seat.Parent:IsA("Model")) and seat.Parent or nil
    local prim = boat and boat.PrimaryPart or nil
    local OrigMaxSpeed = seat.MaxSpeed
    local OrigTurnSpeed = seat.TurnSpeed
    local OrigTorque = seat.Torque
    local start = os.clock()
    local LastCheckPos = seat.Position
    local LastCheckAt = os.clock()
    local LastHeartCheckAt = 0
    local Arrived = false
    local SailStalls = 0
    while _G.AutoLeviathanFull and os.clock() - start < 900 do
        LastSailAt = os.clock()
        if not seat or not seat.Parent or not IsSittingOn(seat) then
            break
        end
        if HeartCheck and os.clock() - LastHeartCheckAt >= 1 then
            LastHeartCheckAt = os.clock()
            if not HeartCheck(seat) then
                break
            end
        end
        if os.clock() - LastCheckAt >= 30 then
            local Moved = (seat.Position - LastCheckPos).Magnitude
            if Moved < 200 then
                SailStalls = SailStalls + 1
                if SailStalls >= 2 then
                    SailStalls = 0
                    LastCheckPos = seat.Position
                    LastCheckAt = os.clock()
                    if _G.RJR_RecoverLock then
                        _G.RJR_RecoverLock("el barco no avanza volviendo a Tiki")
                    end
                    break
                end
                SetStatus("Menos de 200 en 30 s: bajo y vuelvo a subir para reiniciar")
                if not Unseat() then
                    SetStatus("Atascado y no pude bajarme: sigo esperando")
                    LastCheckPos = seat.Position
                    LastCheckAt = os.clock()
                else
                    task.wait(0.5)
                    if not BoardSeatRetry(seat) then
                        break
                    end
                    LastCheckPos = seat.Position
                    LastCheckAt = os.clock()
                end
            else
                SailStalls = 0
                LastCheckPos = seat.Position
                LastCheckAt = os.clock()
            end
        end
        local pos = seat.Position
        local flat = Vector3.new(TargetPos.X - pos.X, 0, TargetPos.Z - pos.Z)
        local distance = flat.Magnitude
        SetStatus("Volviendo a Tiki (dist " .. math.floor(distance) .. ", navegando " .. math.floor(os.clock() - start) .. " s)")
        if distance <= 40 then
            Arrived = true
            pcall(function()
                seat.Throttle = 0
                seat.ThrottleFloat = 0
            end)
            if prim then
                pcall(function()
                    prim.ThrottleFloat = 0
                    prim.Throttle = 0
                end)
            end
            break
        end
        pcall(function()
            seat.MaxSpeed = Speed
            seat.TurnSpeed = Speed
        end)
        local steerAngle = ComputeSteerAngle(seat, TargetPos)
        if math.abs(steerAngle) <= 5 then
            pcall(function()
                seat.Throttle = 1
                seat.ThrottleFloat = 1
            end)
            if prim then
                pcall(function()
                    prim.ThrottleFloat = 1
                    prim.Throttle = 1
                end)
            end
        else
            pcall(function() TurnBoatTowards(seat, TargetPos) end)
            if prim then
                pcall(function()
                    TurnBoatPrimTowards(prim, TargetPos)
                end)
            end
            pcall(function()
                seat.Throttle = 0
                seat.ThrottleFloat = 0
            end)
            if prim then
                pcall(function()
                    prim.ThrottleFloat = 0
                    prim.Throttle = 0
                end)
            end
        end
        task.wait()
    end
    pcall(function()
        seat.Throttle = 0
        seat.ThrottleFloat = 0
        seat.MaxSpeed = OrigMaxSpeed
        seat.TurnSpeed = OrigTurnSpeed
        seat.Torque = OrigTorque
    end)
    if prim then
        pcall(function()
            prim.ThrottleFloat = 0
            prim.Throttle = 0
        end)
    end
    return Arrived
end
local function ReturnTiki(Speed)
    Speed = Speed or 200
    local boat = GetOwnBoat()
    if not boat then
        print("[ReturnTiki] sin barco")
        return false
    end
    local DriverSeat = boat:FindFirstChild("VehicleSeat")
    if not DriverSeat then
        print("[ReturnTiki] sin asiento de conductor")
        return false
    end
    if not BoardSeatRetry(DriverSeat) then
        print("[ReturnTiki] no pude subir al timón")
        return false
    end
    print("[ReturnTiki] ya estoy en el timón")
    SetStatus("Volviendo a Tiki")
    local function HeartCloseCheck(seat)
        local Map = workspace:FindFirstChild("Map")
        local Heart = Map and Map:FindFirstChild("FrozenHeart")
        local HeartPos = Heart and GetHeartPos(Heart)
        if not HeartPos then
            SetStatus("Volviendo a Tiki: el corazón desapareció, cancelo")
            print("[ReturnTiki] heart gone, interrupt leg")
            return false
        end
        local Dist = (HeartPos - seat.Position).Magnitude
        if Dist > 3000 then
            SetStatus("Volviendo a Tiki: corazón a " .. math.floor(Dist) .. " del barco, cancelo")
            print("[ReturnTiki] heart check fail dist=" .. math.floor(Dist))
            return false
        end
        return true
    end
    local TotalStart = os.clock()
    local Returned = false
    while _G.AutoLeviathanFull and os.clock() - TotalStart < 1800 do
        local Map = workspace:FindFirstChild("Map")
        local Heart = Map and Map:FindFirstChild("FrozenHeart")
        if not Heart then
            SetStatus("El corazón desapareció: dejo de volver a Tiki")
            print("[ReturnTiki] heart gone, stop return")
            break
        end
        local HeartPos = Heart and GetHeartPos(Heart)
        if not HeartPos then
            SetStatus("El corazón desapareció: dejo de volver a Tiki")
            print("[ReturnTiki] heart gone, stop return")
            break
        end
        if not DriverSeat or not DriverSeat.Parent or not IsSittingOn(DriverSeat) then
            print("[ReturnTiki] me caí del asiento: vuelvo al timón")
            local b2 = GetOwnBoat()
            if not b2 then
                break
            end
            DriverSeat = b2:FindFirstChild("VehicleSeat")
            if not DriverSeat or not BoardSeatRetry(DriverSeat) then
                break
            end
        end
        local WentToHeart = false
        local BoatPos = DriverSeat.Position
        local Dist3D = (HeartPos - BoatPos).Magnitude
        if Dist3D > 3000 then
            SetStatus("Volviendo a Tiki: corazón a " .. math.floor(Dist3D) .. " — voy justo debajo del corazón")
            print("[ReturnTiki] heart far=" .. math.floor(Dist3D) .. ", sail to heart")
            SailToCF(DriverSeat, CFrame.new(HeartPos.X, BoatPos.Y, HeartPos.Z), Speed)
            SetStatus("Debajo del corazón: espero 1.5 s")
            local HoldStart = os.clock()
            while _G.AutoLeviathanFull and os.clock() - HoldStart < 1.5 do
                task.wait(0.2)
            end
            WentToHeart = true
        end
        if not WentToHeart then
            print("[ReturnTiki] empieza el primer tramo")
            local R1 = SailToCF(DriverSeat, TikiWaypointCF, Speed, HeartCloseCheck)
            print("[ReturnTiki] primer tramo terminado arrived=" .. tostring(R1))
            if R1 then
                local R2 = SailToCF(DriverSeat, TikiReturnCF, Speed, HeartCloseCheck)
                pcall(function()
                    DriverSeat.CFrame = TikiReturnCF
                end)
                print("[ReturnTiki] segundo tramo terminado arrived=" .. tostring(R2))
                if R2 then
                    Returned = true
                    break
                end
            end
        end
    end
    if Returned then
        SetStatus("De vuelta en Tiki: espero a que el corazón desaparezca")
    end
    return Returned
end
local function WaitForTeammates(boat, DriverSeat, ShouldStop, FightEvents, NoRebuy, MaxWait, FarImmediate)
    if FightEvents == nil then
        FightEvents = true
    end
    local FarStart = nil
    local WaitStart = os.clock()
    while _G.AutoLeviathanFull do
        if MaxWait and os.clock() - WaitStart >= MaxWait then
            SetStatus("Se agotó la espera de compañeros")
            return boat, DriverSeat, false
        end
        if ShouldStop and ShouldStop() then
            return boat, DriverSeat, true
        end
        if not IsSittingOn(DriverSeat) then
            SetStatus("Esperando compañeros: el capitán sube al timón primero")
            if not BoardSeatRetry(DriverSeat) then
                local b2 = GetOwnBoat()
                if not b2 then
                    SetStatus("El barco desapareció: vuelvo a comprarlo")
                    return boat, DriverSeat, false
                end
                local s2 = b2:FindFirstChild("VehicleSeat")
                if not s2 then
                    SetStatus("El barco nuevo no tiene timón: vuelvo a comprar")
                    return boat, DriverSeat, false
                end
                boat, DriverSeat = b2, s2
            end
        end
        if not boat or not boat.Parent then
            SetStatus("El barco desapareció mientras esperaba: vuelvo a comprar")
            return boat, DriverSeat, false
        end
        if CountTeammatesOnBoat(boat) >= 4 then
            return boat, DriverSeat, false
        end
        if not NoRebuy then
            local ND = NearestPlayerDistance(boat)
            local RebuyCd = os.clock() - LastRebuyAt
            if FarImmediate then
                if ND > 10000 then
                    if RebuyCd >= 60 then
                        SetStatus("El compañero más cercano está a más de 10000: vuelvo a comprar barco")
                        local b3, s3 = RebuyBoatAndBoard()
                        if b3 and s3 then
                            boat, DriverSeat = b3, s3
                        end
                    else
                        SetStatus("Compañero lejos, recompra en espera: aguardo (" .. math.floor(60 - RebuyCd) .. " s)")
                    end
                end
            elseif ND > 12000 then
                if RebuyCd < 60 then
                    FarStart = nil
                else
                    FarStart = FarStart or os.clock()
                    if os.clock() - FarStart >= 30 then
                        FarStart = nil
                        SetStatus("Compañeros demasiado lejos: vuelvo al muelle a comprar")
                        local b3, s3 = RebuyBoatAndBoard()
                        if b3 and s3 then
                            boat, DriverSeat = b3, s3
                        end
                    end
                end
            else
                FarStart = nil
            end
        else
            FarStart = nil
        end
        local Mob, Root, Skill = SeaAPI.Sea_Mob()
        if FightEvents and Mob and Root then
            SetStatus("Mientras espero, farmeo: " .. Mob.Name)
            if not Unseat() then
                SetStatus("No pude bajarme: sigo intentando pelear")
            end
            local Stuck = {}
            while _G.AutoLeviathanFull do
                if ShouldStop and ShouldStop() then
                    break
                end
                if CountTeammatesOnBoat(boat) >= 4 then
                    break
                end
                local M, R, S = SeaAPI.Sea_Mob(5000, Stuck)
                if not M or not R then
                    break
                end
                SeaAPI.FightSeaEvent(M, R, S)
                if SeaAPI.Sea_MobStillAlive(M) then
                    Stuck[M] = true
                end
                task.wait(0.5)
            end
            if DriverSeat and DriverSeat.Parent then
                BoardSeatRetry(DriverSeat)
            end
        else
            SetStatus("Esperando compañeros a bordo (" .. tostring(CountTeammatesOnBoat(boat)) .. "/4)")
            task.wait(1)
        end
    end
    return boat, DriverSeat, false
end
local function CaptainFarmPhase()
    local boat = GetOwnBoat()
    if not boat then
        BuyOwnBoat()
        local SpawnStart = os.clock()
        while _G.AutoLeviathanFull and not _G.RJR_Resetting and os.clock() - SpawnStart < 20 do
            boat = GetOwnBoat()
            if boat then
                break
            end
            task.wait(0.5)
        end
    end
    if not boat then
        return
    end
    local DriverSeat = boat:FindFirstChild("VehicleSeat")
    if not DriverSeat then
        return
    end
    if not BoardSeatRetry(DriverSeat) then
        SetStatus("No pude subir al timón: vuelvo al bucle principal")
        return
    end
    if _G.SoloSeaFarm then
        SetStatus("Farmeo en solitario: no espero compañeros")
    else
        SetStatus("Esperando a 4 compañeros a bordo")
        boat, DriverSeat = WaitForTeammates(boat, DriverSeat, nil, true, false, nil, true)
        if CountTeammatesOnBoat(boat) >= 4 then
            SetStatus("4 compañeros a bordo: navego en 0.5 s")
            task.wait(0.5)
            SetStatus("4 compañeros a bordo: listos para farmear")
        end
    end
    local FarmDone = false
    local FarmStart = os.clock()
    if not _G.SoloSeaFarm then
        task.spawn(function()
            while _G.AutoLeviathanFull and not FarmDone do
                task.wait(2)
                local S = GetBribeStatus()
                if S == nil or S ~= -1 then
                    FarmDone = true
                end
            end
        end)
    end
    local LastTeamCheck = 0
    local LastMobCheck = 0
    local LastSlowCheck = 0
    local Fought = {}
    local Mob, Root, Skill = nil, nil, false
    while _G.AutoLeviathanFull and not FarmDone do
        if os.clock() - LastSlowCheck >= 0.4 then
            LastSlowCheck = os.clock()
            local MapX = workspace:FindFirstChild("Map")
            if SeaAPI.Leviathan_SegmentsExist() or (MapX and MapX:FindFirstChild("LeviathanGate")) then
                SetStatus("Leviathan apareció: dejo el farmeo y voy a cazarlo")
                break
            end
            local b2 = GetOwnBoat()
            local s2 = b2 and b2:FindFirstChild("VehicleSeat")
            if b2 and s2 then
                boat = b2
                DriverSeat = s2
            elseif _G.AutoLeviathanFull then
                local _, _, humR = GetCharacterParts()
                if humR and humR.Health > 0 then
                    local b3, s3 = RebuyBoatAndBoard()
                    if b3 and s3 then
                        boat, DriverSeat = b3, s3
                    end
                end
            end
        end
        if os.clock() - LastTeamCheck >= 1 then
            LastTeamCheck = os.clock()
            if not _G.SoloSeaFarm and CountTeammatesOnBoat(boat) < 4 then
                local b3, s3, Stopped = WaitForTeammates(boat, DriverSeat, function()
                    return FarmDone
                end, true, false, nil, true)
                boat, DriverSeat = b3, s3
                if Stopped then
                    break
                end
                task.wait(0.5)
            else
                local b2 = GetOwnBoat()
                local s2 = b2 and b2:FindFirstChild("VehicleSeat")
                if b2 and s2 then
                    boat, DriverSeat = b2, s2
                end
            end
        end
        if os.clock() - LastMobCheck >= 0.2 then
            LastMobCheck = os.clock()
            Mob, Root, Skill = SeaAPI.Sea_Mob(1500, Fought)
        end
        if Mob and Root then
            SetStatus("Farmeo marino: peleando a pie")
            if not Unseat() then
                SetStatus("No pude bajarme: sigo intentando pelear")
            end
            while _G.AutoLeviathanFull and not FarmDone do
                local M, R, S = SeaAPI.Sea_Mob(5000, Fought)
                if not M or not R then
                    break
                end
                SeaAPI.FightSeaEvent(M, R, S)
                if SeaAPI.Sea_MobStillAlive(M) then
                    Fought[M] = true
                end
                task.wait(0.5)
            end
            if DriverSeat and DriverSeat.Parent then
                BoardSeatRetry(DriverSeat)
            end
            LastTeamCheck = 0
            LastMobCheck = 0
        else
            if not DriverSeat or not DriverSeat.Parent then
                task.wait(0.2)
            elseif not IsSittingOn(DriverSeat) then
                BoardSeat(DriverSeat, 3)
            else
                SetStatus("Farmeo marino: patrullando (llevo " .. math.floor(os.clock() - FarmStart) .. " s)")
                local staying = SailBoatStream(DriverSeat, _G.BoatSpeed)
                if staying == false then
                    local b3, s3 = RebuyBoatAndBoard()
                    if b3 and s3 then
                        boat, DriverSeat = b3, s3
                    end
                end
            end
        end
    end
end
local function RunNav(fn)
    return pcall(fn)
end
local function HeartFinishPhase()
    if _G.AutoLeviathanFull and not GetOwnBoat() then
        BuyOwnBoat("Corazón presente y sin barco: voy a comprar uno")
        local BoatWaitStart = os.clock()
        while _G.AutoLeviathanFull and not _G.RJR_Resetting and os.clock() - BoatWaitStart < 30 do
            if GetOwnBoat() then
                break
            end
            task.wait(0.5)
        end
    end
    local Grabbed = HarpoonHeart()
    if not Grabbed then
        return
    end
    SetStatus("Corazón enganchado: subo al barco en 5 s")
    local PreSyncStart = os.clock()
    while _G.AutoLeviathanFull and os.clock() - PreSyncStart < 5 do
        task.wait(0.5)
    end
    local boat = GetOwnBoat()
    local DriverSeat = boat and boat:FindFirstChild("VehicleSeat")
    if DriverSeat and not IsSittingOn(DriverSeat) then
        SetStatus("Corazón enganchado: subo al timón")
        BoardSeatRetry(DriverSeat)
    end
    SetStatus("En el timón: vuelvo a Tiki en 10 s")
    local PostBoardStart = os.clock()
    while _G.AutoLeviathanFull and os.clock() - PostBoardStart < 10 do
        task.wait(0.5)
    end
    local Returned = ReturnTiki(120)
    local HeartLockDone = false
    if Returned then
        task.spawn(function()
            while _G.AutoLeviathanFull and not HeartLockDone do
                pcall(function()
                    local bL = GetOwnBoat()
                    local sL = bL and bL:FindFirstChild("VehicleSeat")
                    if sL and IsSittingOn(sL) then
                        local _, hrpL = GetCharacterParts()
                        if hrpL then
                            hrpL.CFrame = CFrame.new(TikiReturnCF.Position.X, hrpL.Position.Y, TikiReturnCF.Position.Z) * (hrpL.CFrame - hrpL.CFrame.Position)
                        end
                        sL.ThrottleFloat = 1
                        sL.SteerFloat = 0
                    end
                end)
                task.wait(0.2)
            end
        end)
    end
    local WaitStart = os.clock()
    local LastHeartScan = 0
    while _G.AutoLeviathanFull and os.clock() - WaitStart < 1800 do
        local Map = workspace:FindFirstChild("Map")
        local Heart = Map and Map:FindFirstChild("FrozenHeart")
        local HeartGone = not Heart
        if Heart and Heart:IsA("BasePart") then
            HeartGone = Heart.Transparency >= 1
        elseif Heart then
            local primary = Heart:IsA("Model") and Heart.PrimaryPart
            local PrimaryGone = primary == nil or primary.Transparency >= 1
            if PrimaryGone and os.clock() - LastHeartScan >= 5 then
                LastHeartScan = os.clock()
                local AnyVisible = false
                for _, p in ipairs(Heart:GetDescendants()) do
                    if p:IsA("BasePart") and p.Transparency < 1 then
                        AnyVisible = true
                        break
                    end
                end
                HeartGone = not AnyVisible
            end
        end
        if HeartGone then
            HeartLockDone = true
            SetStatus("El corazón desapareció: voy al muelle a comprar barco")
            break
        end
        if not Returned and not Heart then
            HeartLockDone = true
            SetStatus("El barco desapareció: compro uno nuevo sin esperar el corazón")
            break
        end
        SetStatus("Esperando a que el corazón desaparezca (llevo " .. math.floor(os.clock() - WaitStart) .. " s)")
        task.wait(2)
    end
    HeartLockDone = true
    if not _G.AutoLeviathanFull then
        return
    end
    if not Unseat() then
        SetStatus("El corazón desapareció y no pude bajarme: voy igual a comprar")
    end
    local OldBoat = GetOwnBoat()
    BuyOwnBoat("Corazón desaparecido: voy al muelle a comprar barco")
    local SpawnStart = os.clock()
    while _G.AutoLeviathanFull and not _G.RJR_Resetting and os.clock() - SpawnStart < 20 do
        local b3 = GetOwnBoat()
        if b3 and b3 ~= OldBoat then
            break
        end
        task.wait(0.5)
    end
end
local HuntStart = nil
local function CaptainHuntPhase()
    if HuntStart == nil then
        HuntStart = os.clock()
    end
    local HuntSuccess = false
    local MapEarly = workspace:FindFirstChild("Map")
    if SeaAPI.Leviathan_SegmentsExist() or (MapEarly and MapEarly:FindFirstChild("LeviathanGate")) then
        HuntSuccess = true
    end
    local boat = nil
    local DriverSeat = nil
    if not HuntSuccess then
        boat = GetOwnBoat()
        if not boat then
            BuyOwnBoat()
            local SpawnStart = os.clock()
            while _G.AutoLeviathanFull and not _G.RJR_Resetting and os.clock() - SpawnStart < 20 do
                boat = GetOwnBoat()
                if boat then
                    break
                end
                task.wait(0.5)
            end
        end
        if not boat then
            return
        end
        DriverSeat = boat:FindFirstChild("VehicleSeat")
        if not DriverSeat then
            return
        end
        if not BoardSeatRetry(DriverSeat) then
            SetStatus("No pude subir al timón: vuelvo al bucle principal")
            return
        end
        NoClip(true)
    end
    local LastHuntCheck = 0
    local LastTeamCheck2 = 0
    local LastMobCheck = 0
    while _G.AutoLeviathanFull and not HuntSuccess do
        if not boat or not boat.Parent or _G.RJR_AbandonedBoats[boat] then
            SetStatus("El barco desapareció durante la caza: vuelvo al bucle principal")
            return
        end
        if not IsSittingOn(DriverSeat) then
            SetStatus("Me caí del asiento: vuelvo al timón")
            if not BoardSeatRetry(DriverSeat, 5, 2) then
                SetStatus("No pude volver al barco: vuelvo al bucle principal")
                return
            end
        end
        if os.clock() - LastHuntCheck >= 0.2 then
            LastHuntCheck = os.clock()
            local Map = workspace:FindFirstChild("Map")
            if SeaAPI.Leviathan_SegmentsExist() or (Map and Map:FindFirstChild("LeviathanGate")) then
                SetStatus("La puerta del Leviathan apareció: detengo el barco")
                HuntSuccess = true
                break
            end
            SetStatus("Buscando al Leviathan: navegando (llevo " .. math.floor(os.clock() - HuntStart) .. " s)")
        end
        if os.clock() - LastTeamCheck2 >= 1 then
            LastTeamCheck2 = os.clock()
            if not _G.SoloSeaFarm and CountTeammatesOnBoat(boat) < 4 then
                local b3, s3 = WaitForTeammates(boat, DriverSeat, nil, false)
                boat, DriverSeat = b3, s3
                if not boat or not DriverSeat or not boat.Parent then
                    SetStatus("El barco desapareció mientras esperaba: dejo la caza")
                    return
                end
                task.wait(0.5)
                SetStatus("Buscando al Leviathan: sigo navegando")
            end
        end
        if _G.HuntFightEvents and os.clock() - LastMobCheck >= 0.5 then
            LastMobCheck = os.clock()
            local Mob, Root, Skill = SeaAPI.Sea_Mob(5000)
            if Mob and Root then
                SetStatus("De caza: farmeo " .. Mob.Name)
                if not Unseat() then
                    SetStatus("No pude bajarme: sigo intentando pelear")
                end
                local Stuck = {}
                while _G.AutoLeviathanFull do
                    local MapX = workspace:FindFirstChild("Map")
                    if SeaAPI.Leviathan_SegmentsExist() or (MapX and MapX:FindFirstChild("LeviathanGate")) then
                        break
                    end
                    local M, R, S = SeaAPI.Sea_Mob(5000, Stuck)
                    if not M or not R then
                        break
                    end
                    SeaAPI.FightSeaEvent(M, R, S, function()
                        local MapX2 = workspace:FindFirstChild("Map")
                        return SeaAPI.Leviathan_SegmentsExist() or (MapX2 and MapX2:FindFirstChild("LeviathanGate"))
                    end)
                    if SeaAPI.Sea_MobStillAlive(M) then
                        Stuck[M] = true
                    end
                    task.wait(0.5)
                end
                if DriverSeat and DriverSeat.Parent then
                    BoardSeatRetry(DriverSeat)
                end
                LastTeamCheck2 = 0
            end
        end
        local staying = SailBoatStream(DriverSeat, _G.BoatSpeed)
        if staying == false then
            local b3, s3 = RebuyBoatAndBoard()
            if b3 and s3 then
                boat, DriverSeat = b3, s3
            end
        end
    end
    if not HuntSuccess then
        SetStatus("La caza terminó con error: reinicio")
        return
    end
    HuntStart = nil
    if not Unseat() then
        SetStatus("No pude bajarme: reintento")
        return
    end
    OpenLeviathanGate()
    local Killed = SeaAPI.FightLeviathan(nil, 6)
    if not Killed then
        SetStatus("Leviathan no derrotado: reinicio")
        return
    end
    SetStatus("Leviathan derrotado")
    if _G.AutoLeviathanFull and not GetOwnBoat() then
        BuyOwnBoat()
        local BoatWaitStart = os.clock()
        while _G.AutoLeviathanFull and not _G.RJR_Resetting and os.clock() - BoatWaitStart < 30 do
            if GetOwnBoat() then
                break
            end
            task.wait(0.5)
        end
    end
    local HeartStart = os.clock()
    while _G.AutoLeviathanFull and os.clock() - HeartStart < 900 do
        local Map = workspace:FindFirstChild("Map")
        if Map and Map:FindFirstChild("FrozenHeart") then
            SetStatus("El corazón apareció: engancho en 20 s")
            break
        end
        SetStatus("Esperando a que aparezca el corazón (llevo " .. math.floor(os.clock() - HeartStart) .. " s)")
        task.wait(1)
    end
    local PostHeartStart = os.clock()
    while _G.AutoLeviathanFull and os.clock() - PostHeartStart < 25 do
        SetStatus("El corazón apareció: engancho en 25 s (llevo " .. math.floor(os.clock() - PostHeartStart) .. " s)")
        task.wait(0.5)
    end
    HeartFinishPhase()
end
local CaptainRunning = false
local function StartCaptain()
    if CaptainRunning then
        return
    end
    CaptainRunning = true
    task.spawn(function()
        while _G.AutoLeviathanFull and _G.Mode == "Capitán" do
            StatusPrefix = ""
            local ok, err = pcall(function()
                local Map = workspace:FindFirstChild("Map")
                local Heart = Map and Map:FindFirstChild("FrozenHeart")
                if Heart then
                    SetStatus("Corazón detectado: continúo con el enganche")
                    HeartFinishPhase()
                    return
                end
                if not _G.SoloSeaFarm then
                    local S = GetBribeStatus()
                    if S == nil then
                        SetStatus("Esperando el estado del soborno (no disponible)")
                        task.wait(2)
                        return
                    end
                    if S ~= -1 and S ~= 5 then
                        SetStatus("Soborno incompleto (" .. tostring(S) .. "/5): soborno ahora")
                        BribeUntilDone()
                        S = GetBribeStatus()
                    end
                    if SeaAPI.Leviathan_SegmentsExist() or (Map and Map:FindFirstChild("LeviathanGate")) then
                        SetStatus("Leviathan detectado: voy a cazarlo")
                        RunNav(CaptainHuntPhase)
                        return
                    end
                    if S == 5 then
                        SetStatus("Soborno completado: empiezo la caza del Leviathan")
                        RunNav(CaptainHuntPhase)
                    else
                        SetStatus("Soborno incompleto: farmeo eventos mientras espero")
                        RunNav(CaptainFarmPhase)
                    end
                else
                    if SeaAPI.Leviathan_SegmentsExist() or (Map and Map:FindFirstChild("LeviathanGate")) then
                        SetStatus("Leviathan detectado: voy a cazarlo")
                        RunNav(CaptainHuntPhase)
                    else
                        SetStatus("Farmeo en solitario: empiezo a patrullar")
                        RunNav(CaptainFarmPhase)
                    end
                end
            end)
            if not ok then
                task.wait(0.5)
            end
            task.wait(1)
        end
        CaptainRunning = false
    end)
end
local FollowerRunning = false
local LastLeviathanSeen = 0
local FollowSeatsFull = false
local function IsOnCaptainBoat(boat)
    local _, _, hum = GetCharacterParts()
    if not hum or not hum.SeatPart then
        return false
    end
    return hum.SeatPart:IsDescendantOf(boat)
end
local function IsCaptainOnBoat(boat)
    local captain = Players:FindFirstChild(_G.FollowTarget)
    local char = captain and captain.Character
    local hum = char and char:FindFirstChildOfClass("Humanoid")
    local DriverSeat = boat and boat:FindFirstChild("VehicleSeat")
    return hum ~= nil and DriverSeat ~= nil and hum.SeatPart == DriverSeat
end
local function FollowerBoardSeat(boat)
    local cannons = GetCannons(boat)
    local _, hrp0 = GetCharacterParts()
    local firstSeat = boat and (boat:FindFirstChild("VehicleSeat") or cannons[1])
    if hrp0 and firstSeat and (hrp0.Position - firstSeat.Position).Magnitude > 2500 then
        if (hrp0.Position - firstSeat.Position).Magnitude > BoatFindRange then
            SetStatus("Siguiendo: el barco del capitán está a más de " .. BoatFindRange .. " — no lo persigo")
            return false
        end
        SetStatus("Siguiendo: el barco está lejos, me acerco volando")
        ClearHover()
        local FlyStart = os.clock()
        while _G.AutoLeviathanFull and os.clock() - FlyStart < 30 do
            local _, hrp1 = GetCharacterParts()
            if not hrp1 or not firstSeat or not firstSeat.Parent then
                break
            end
            if (hrp1.Position - firstSeat.Position).Magnitude <= 500 then
                break
            end
            _tp(function()
                return firstSeat.Parent and firstSeat.CFrame or nil
            end, function()
                local _, h = GetCharacterParts()
                return (not firstSeat.Parent) or (not h)
                    or (firstSeat.Position - h.Position).Magnitude <= 500
            end)
            task.wait(0.1)
        end
    end
    local tried = {}
    local BoardStart = os.clock()
    while _G.AutoLeviathanFull and os.clock() - BoardStart < 25 do
        local seat = nil
        for _, cannon in ipairs(cannons) do
            local s = cannon:FindFirstChild("Seat")
            if s and not IsSeatOccupied(s) and not tried[s] then
                seat = s
                break
            end
        end
        if not seat then
            SetStatus("Siguiendo: no hay asientos libres (¿4/4?)")
            FollowSeatsFull = true
            return false
        end
        SetStatus("Siguiendo: pruebo el asiento " .. seat.Parent.Name .. " (cambio cada 1 s)")
        if BoardSeat(seat, 0.5) then
            FollowSeatsFull = false
            return true
        end
        tried[seat] = true
    end
    return false
end
local function FollowerHeartWait()
    pcall(function()
        if CurrentTween then
            CurrentTween:Cancel()
            CurrentTween = nil
        end
    end)
    Tweening = false
    Unseat()
    local StartAt = os.clock()
    local StatusAt = 0
    local LastTPPos = nil
    while _G.AutoLeviathanFull and _G.Mode == "Seguidor" do
        local Map = workspace:FindFirstChild("Map")
        local Heart = Map and Map:FindFirstChild("FrozenHeart")
        if not Heart then
            SetStatus("El corazón desapareció: subo al barco a seguir")
            return
        end
        local hp = GetHeartPos(Heart)
        if hp and (LastTPPos == nil or (hp - LastTPPos).Magnitude > 20) then
            LastTPPos = hp
            _tp(LiveHeartCF(35), function()
                return not _G.AutoLeviathanFull
            end)
        end
        if os.clock() - StatusAt > 2 then
            StatusAt = os.clock()
            SetStatus("Esperando el corazón: me teletransporto (llevo " .. math.floor(os.clock() - StartAt) .. " s)")
        end
        task.wait(1)
    end
end
local function StartFollower()
    if FollowerRunning then
        return
    end
    FollowerRunning = true
    local function CaptainBackOnBoat()
        local boat = GetCaptainBoat()
        return IsCaptainOnBoat(boat)
    end
    task.spawn(function()
        local GateTweening = false
        while _G.AutoLeviathanFull and _G.Mode == "Seguidor" do
            StatusPrefix = "follow"
            local ok, err = pcall(function()
                local boat = GetCaptainBoat()
                local DriverSeat = boat and boat:FindFirstChild("VehicleSeat")
                local CaptainOn = boat ~= nil and IsCaptainOnBoat(boat)
                local Map = workspace:FindFirstChild("Map")
                local Heart = Map and Map:FindFirstChild("FrozenHeart")
                local HeartPos = Heart and GetHeartPos(Heart)
                local HeartGrabbed = HeartPos ~= nil and HeartPos.Y < 110
                if Heart then
                    FollowerHeartWait()
                    return
                end
                if HeartGrabbed then
                    if boat then
                        if not IsOnCaptainBoat(boat) then
                            SetStatus("Corazón enganchado: subo al cañón")
                            FollowerBoardSeat(boat)
                        else
                            SetStatus("En espera en el barco (corazón enganchado)")
                        end
                    else
                        if GetCaptainHRP() then
                            SetStatus("Corazón enganchado: sigo al capitán")
                            _tp(LiveCaptainTopCF(35), function()
                                return not _G.AutoLeviathanFull
                            end)
                        end
                    end
                    return
                end
                local LV = SeaAPI.Leviathan_Find()
                if LV then
                    if GateTweening then
                        GateTweening = false
                        pcall(function()
                            if CurrentTween then
                                CurrentTween:Cancel()
                                CurrentTween = nil
                            end
                        end)
                        Tweening = false
                        SetStatus("Leviathan apareció: cancelo el viaje a la puerta")
                    end
                    if boat and IsOnCaptainBoat(boat) then
                        if not Unseat() then
                            SetStatus("Leviathan apareció y no pude bajarme: reintentando")
                        else
                            SetStatus("Leviathan apareció: me bajo a pelear")
                        end
                    end
                    LastLeviathanSeen = os.clock()
                    SeaAPI.FightLeviathan(CaptainBackOnBoat, 10)
                    return
                end
                if boat and CaptainOn then
                    if not IsOnCaptainBoat(boat) then
                        FollowerBoardSeat(boat)
                    else
                        SetStatus("En espera en el barco (capitán " .. (_G.FollowTarget or "?") .. " al timón)")
                    end
                else
                    if boat and IsOnCaptainBoat(boat) then
                        if not Unseat() then
                            SetStatus("El capitán bajó y yo no puedo: reintentando")
                        else
                            SetStatus("El capitán bajó: bajo también")
                        end
                    elseif not boat then
                        SetStatus("Barco del capitán perdido: peleo mientras compra otro")
                    end
                    local MapG = workspace:FindFirstChild("Map")
                    local Gate = MapG and MapG:FindFirstChild("LeviathanGate")
                    local Watcher = Gate and Gate:FindFirstChild("FrozenWatcherPart")
                    if Watcher and SeaAPI.Leviathan_SegmentsExist() then
                        if GateTweening then
                            GateTweening = false
                            pcall(function()
                                if CurrentTween then
                                    CurrentTween:Cancel()
                                    CurrentTween = nil
                                end
                            end)
                            Tweening = false
                            SetStatus("Leviathan apareció: fuerzo salir del viaje a la puerta")
                        end
                    elseif Watcher and os.clock() - LastLeviathanSeen >= 120 then
                        GateTweening = true
                        local WatcherPos = TargetPos(Watcher)
                        if WatcherPos then
                            SetStatus("La puerta del Leviathan apareció: me teletransporto")
                            _tp(LiveGateCF(5), function()
                                return (not _G.AutoLeviathanFull) or SeaAPI.Leviathan_SegmentsExist()
                            end)
                            GateTweening = false
                            RestorePlayerState()
                            SetStatus("En la puerta del Leviathan: esperando a que aparezca")
                        end
                    elseif Heart then
                        local HeartPos2 = GetHeartPos(Heart)
                        if HeartPos2 then
                            SetStatus("Me teletransporto al corazón")
                            _tp(LiveHeartCF(35), function()
                                return not _G.AutoLeviathanFull
                            end)
                        end
                    elseif os.clock() - LastLeviathanSeen < 120 then
                        local capHrp = GetCaptainHRP()
                        if capHrp then
                            SetStatus("Siguiendo al capitán (esperando el corazón)")
                            _tp(LiveCaptainTopCF(35), function()
                                return not _G.AutoLeviathanFull
                            end)
                        end
                    else
                        local Mob, Root, Skill = SeaAPI.Sea_Mob(5000)
                        if Mob and Root then
                            SeaAPI.FightSeaEvent(Mob, Root, Skill, CaptainBackOnBoat)
                        else
                            SetStatus("El capitán está a pie, sin objetivo: en espera")
                            if not IsOnBoat() then
                                if GetCaptainHRP() then
                                    _tp(LiveCaptainTopCF(35), function()
                                        return not _G.AutoLeviathanFull
                                    end)
                                else
                                    _tp(LiveSelfCF(50), function()
                                        return not _G.AutoLeviathanFull
                                    end)
                                end
                            end
                        end
                    end
                end
            end)
            if not ok then
                task.wait(0.5)
            end
            if FollowSeatsFull and not IsOnBoat() then
                if GetCaptainHRP() then
                    _tp(LiveCaptainTopCF(35), function()
                        return not _G.AutoLeviathanFull
                    end)
                else
                    _tp(LiveSelfCF(50), function()
                        return not _G.AutoLeviathanFull
                    end)
                end
            end
            task.wait(0.2)
        end
        FollowerRunning = false
    end)
end
local function GetStatusDetails()
    local lines = {}
    if not _G.AutoLeviathanFull then
        return T("notstarted")
    end
    lines[#lines + 1] = T("sec.mode") .. ": " .. ModeDisplay()
    if _G.Mode == "Seguidor" then
        lines[#lines + 1] = T("detail.follow") .. ": " .. (_G.FollowTarget ~= "" and _G.FollowTarget or T("detail.no.captain"))
    end
    local boat = nil
    if _G.Mode == "Capitán" then
        boat = GetOwnBoat()
    else
        boat = GetCaptainBoat()
    end
    if boat then
        lines[#lines + 1] = T("detail.teammates") .. ": " .. CountTeammatesOnBoat(boat) .. "/4"
    else
        lines[#lines + 1] = T("detail.teammates") .. ": " .. T("detail.no.boat")
    end
    local _, _, hum = GetCharacterParts()
    if hum and hum.SeatPart then
        lines[#lines + 1] = T("detail.seat") .. ": " .. hum.SeatPart.Name
    elseif hum then
        lines[#lines + 1] = T("detail.seat") .. ": " .. T("detail.not.seated")
    end
    local S = GetBribeStatus()
    if S ~= nil then
        if S == -1 then
            lines[#lines + 1] = T("detail.bribe") .. ": " .. T("bribe.cd")
        elseif S == 5 then
            lines[#lines + 1] = T("detail.bribe") .. ": " .. T("bribe.done")
        else
            lines[#lines + 1] = T("detail.bribe") .. ": " .. tostring(S) .. "/5"
        end
    else
        lines[#lines + 1] = T("detail.bribe") .. ": " .. T("bribe.unknown")
    end
    return table.concat(lines, "\n")
end
local function GetTargetStatus()
    local lines = {}
    if not _G.AutoLeviathanFull then
        return T("notstarted")
    end
    local LV, part = SeaAPI.Leviathan_Find()
    if LV then
        local HP = SeaAPI.Leviathan_GetHP(LV)
        lines[#lines + 1] = T("tab.main") .. ": " .. LV.Name
            .. (HP and (" " .. T("target.hp") .. " " .. string.format("%.0f", HP)) or "")
    else
        local Map = workspace:FindFirstChild("Map")
        if Map and Map:FindFirstChild("LeviathanGate") then
            lines[#lines + 1] = T("tab.main") .. ": " .. T("target.gate")
        else
            lines[#lines + 1] = T("tab.main") .. ": " .. T("target.not.spawned")
        end
    end
    local Map2 = workspace:FindFirstChild("Map")
    local Heart = Map2 and Map2:FindFirstChild("FrozenHeart")
    if Heart then
        local P = GetHeartPos(Heart)
        if P and P.Y < 110 then
            lines[#lines + 1] = T("target.heart") .. ": " .. T("target.hooked")
        else
            lines[#lines + 1] = T("target.heart") .. ": " .. T("target.spawned")
        end
    else
        lines[#lines + 1] = T("target.heart") .. ": " .. T("target.not.spawned")
    end
    return table.concat(lines, "\n")
end
local InfoUIFrame = nil
local InfoUIText = nil
local function BuildInfoUIContent()
    if not _G.ShowInfoUI then
        return ""
    end
    local lines = {}
    lines[#lines + 1] = "Auto Leviathan"
    lines[#lines + 1] = "━━━━━━━━━━━━━━━━"
    local S = GetBribeStatus()
    if S ~= nil then
        if S == -1 then
            lines[#lines + 1] = T("ui.bribe") .. ": " .. T("bribe.cd")
        elseif S == 5 then
            lines[#lines + 1] = T("ui.bribe") .. ": " .. T("bribe.done")
        else
            lines[#lines + 1] = T("ui.bribe") .. ": " .. tostring(S) .. "/5"
        end
    else
        lines[#lines + 1] = T("ui.bribe") .. ": " .. T("bribe.unknown")
    end
    local boat = nil
    if _G.Mode == "Capitán" then
        boat = GetOwnBoat()
    else
        boat = GetCaptainBoat()
    end
    if boat then
        lines[#lines + 1] = T("ui.teammates") .. ": " .. CountTeammatesOnBoat(boat) .. "/4"
    else
        lines[#lines + 1] = T("ui.teammates") .. ": " .. T("detail.no.boat")
    end
    lines[#lines + 1] = T("ui.details") .. ": " .. (StatusText ~= "" and StatusText or "-")
    local LV = SeaAPI.Leviathan_Find()
    if LV then
        local HP = SeaAPI.Leviathan_GetHP(LV)
        lines[#lines + 1] = T("tab.main") .. ": " .. LV.Name .. (HP and (" " .. T("target.hp") .. " " .. string.format("%.0f", HP)) or "")
    end
    local Map = workspace:FindFirstChild("Map")
    local Heart = Map and Map:FindFirstChild("FrozenHeart")
    if Heart then
        local P = GetHeartPos(Heart)
        if P and P.Y < 110 then
            lines[#lines + 1] = T("target.heart") .. ": " .. T("target.hooked")
        else
            lines[#lines + 1] = T("target.heart") .. ": " .. T("target.spawned")
        end
    else
        lines[#lines + 1] = T("target.heart") .. ": " .. T("target.not.spawned")
    end
    return table.concat(lines, "\n")
end
local function CreateInfoUI()
    if InfoUIFrame then
        return
    end
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "AutoLeviathanInfo"
    ScreenGui.ResetOnSpawn = false
    ScreenGui.IgnoreGuiInset = true
    ScreenGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
    InfoUIFrame = Instance.new("Frame")
    InfoUIFrame.Name = "Main"
    InfoUIFrame.BackgroundColor3 = Color3.fromRGB(25, 20, 35)
    InfoUIFrame.BackgroundTransparency = 0.05
    InfoUIFrame.BorderSizePixel = 0
    InfoUIFrame.Position = UDim2.new(0.5, -160, 0, 12)
    InfoUIFrame.Size = UDim2.new(0, 320, 0, 0)
    InfoUIFrame.Parent = ScreenGui
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 12)
    Corner.Parent = InfoUIFrame
    local Stroke = Instance.new("UIStroke")
    Stroke.Color = Color3.fromRGB(150, 60, 255)
    Stroke.Thickness = 2
    Stroke.Parent = InfoUIFrame
    local TitleBar = Instance.new("Frame")
    TitleBar.Name = "TitleBar"
    TitleBar.BackgroundColor3 = Color3.fromRGB(150, 60, 255)
    TitleBar.BackgroundTransparency = 0.9
    TitleBar.Size = UDim2.new(1, 0, 0, 8)
    TitleBar.Parent = InfoUIFrame
    local TitleCorner = Instance.new("UICorner")
    TitleCorner.CornerRadius = UDim.new(0, 12)
    TitleCorner.Parent = TitleBar
    InfoUIText = Instance.new("TextLabel")
    InfoUIText.BackgroundTransparency = 1
    InfoUIText.Position = UDim2.new(0, 12, 0, 12)
    InfoUIText.Size = UDim2.new(1, -24, 1, -18)
    InfoUIText.Font = Enum.Font.Gotham
    InfoUIText.TextSize = 14
    InfoUIText.TextColor3 = Color3.fromRGB(240, 240, 245)
    InfoUIText.TextXAlignment = Enum.TextXAlignment.Left
    InfoUIText.TextYAlignment = Enum.TextYAlignment.Top
    InfoUIText.TextWrapped = true
    InfoUIText.RichText = true
    InfoUIText.Parent = InfoUIFrame
    local dragging = false
    local dragOffset = Vector2.zero
    local UIS = game:GetService("UserInputService")
    InfoUIFrame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            local mp = Vector2.new(input.Position.X, input.Position.Y)
            dragOffset = mp - InfoUIFrame.AbsolutePosition
        end
    end)
    UIS.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = false
        end
    end)
    UIS.InputChanged:Connect(function(input)
        if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
            local mp = Vector2.new(input.Position.X, input.Position.Y)
            local newPos = mp - dragOffset
            InfoUIFrame.Position = UDim2.new(0, newPos.X, 0, newPos.Y)
        end
    end)
    local initContent = BuildInfoUIContent()
    if InfoUIText then
        InfoUIText.Text = initContent
    end
    local initLines = #initContent:split("\n")
    InfoUIFrame:SetAttribute("LastText", initContent)
    InfoUIFrame:SetAttribute("LastLines", initLines)
    InfoUIFrame.Size = UDim2.new(0, 320, 0, math.max(40, initLines * 22 + 18))
end
local function UpdateInfoUI()
    if not InfoUIFrame then
        return
    end
    local content = BuildInfoUIContent()
    if content == InfoUIFrame:GetAttribute("LastText") then
        return
    end
    if InfoUIText then
        InfoUIText.Text = content
    end
    local lines = #content:split("\n")
    if lines ~= InfoUIFrame:GetAttribute("LastLines") then
        InfoUIFrame.Size = UDim2.new(0, 320, 0, math.max(40, lines * 22 + 18))
        InfoUIFrame:SetAttribute("LastLines", lines)
    end
    InfoUIFrame:SetAttribute("LastText", content)
end
local function DestroyInfoUI()
    if InfoUIFrame then
        local parent = InfoUIFrame.Parent
        if parent then
            pcall(function()
                parent:Destroy()
            end)
        end
        InfoUIFrame = nil
        InfoUIText = nil
    end
end
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.ShowInfoUI then
            if not InfoUIFrame then
                CreateInfoUI()
            end
            UpdateInfoUI()
        else
            if InfoUIFrame then
                DestroyInfoUI()
            end
        end
    end
end)
RunService.Heartbeat:Connect(function()
    if tick() - LastAttackTime < 0.1 then
        return
    end
    if _G.AutoLeviathanFull and _G.FastAttack then
        local _, _, hum = GetCharacterParts()
        if hum and hum.SeatPart == nil and not hum.Sit then
            pcall(Attack_Auto)
        end
        LastAttackTime = tick()
    end
end)
local function HandleAbility(abilityType)
    task.spawn(function()
        while true do
            if _G["Auto" .. abilityType] then
                if abilityType == "V4" then
                    local Awakening = LocalPlayer:FindFirstChild("Backpack") and LocalPlayer.Backpack:FindFirstChild("Awakening")
                    if Awakening and Awakening:FindFirstChild("RemoteFunction") then
                        pcall(function()
                            Awakening.RemoteFunction:InvokeServer(true)
                        end)
                    end
                elseif abilityType == "V3" then
                    local Remotes = RS:FindFirstChild("Remotes")
                    local CommE2 = Remotes and Remotes:FindFirstChild("CommE")
                    if CommE2 then
                        pcall(function()
                            CommE2:FireServer("ActivateAbility")
                        end)
                    end
                end
            end
            task.wait(1)
        end
    end)
end
HandleAbility("V3")
HandleAbility("V4")
RunService.Heartbeat:Connect(function()
    if _G.AutoLeviathanFull and HRP then
        if not IsOnBoat() then
            HRP.AssemblyLinearVelocity = Vector3.zero
        end
    end
end)
local function DoRemoveFog()
    local layers = game:GetService("Lighting"):FindFirstChild("LightingLayers")
    if layers then
        layers:Destroy()
    end
end
local PerformanceAPI = {}
do
    local function ClickGameSetting(name, enableFirstButton)
        local gui = LocalPlayer:WaitForChild("PlayerGui", 15)
        local main = gui and gui:WaitForChild("Main", 15)
        local menu = main and main:WaitForChild("SettingsMenu", 15)
        local content = menu and menu:WaitForChild("Content", 15)
        local list = content and content:WaitForChild("ScrollingFrame", 15)
        local row = list and list:WaitForChild(name, 9)
        local button = row and row:WaitForChild(enableFirstButton and "FirstButton" or "SecondButton", 9)
        if button then firesignal(button.Activated) end
    end
    PerformanceAPI.ApplyAntiDracoAura = function()
        pcall(function() setfflag("RemoteEventSingleInvocationSizeLimit", "2900") end)
    end
    PerformanceAPI.ApplyAutoFastMode = function()
        task.spawn(function()
            pcall(function()
                ClickGameSetting("FastMode", true)
                local Env = (getgenv and getgenv()) or _G
                if Env.FastMode or Env.reducing then return end
                Env.reducing, Env.FastMode = true, true
                Env.FastModeCache = Env.FastModeCache or {}
                local Replicated = game:GetService("ReplicatedStorage")
                local function Reduce(descendants)
                    local sliceStarted = os.clock()
                    for _, item in next, descendants do
                        if item:IsA("BasePart") then
                            Env.FastModeCache[item] = item.Material
                            item.Material = Enum.Material.SmoothPlastic
                        elseif item:IsA("Texture") and not item:GetAttribute("Offset") then
                            item:Destroy()
                        end
                        if os.clock() - sliceStarted > 0.0083 then task.wait(); sliceStarted = os.clock() end
                    end
                end
                local map, unloaded = workspace:FindFirstChild("Map"), Replicated:FindFirstChild("Unloaded")
                if map then Reduce(map:GetDescendants()) end
                if unloaded then Reduce(unloaded:GetDescendants()) end
                local optimizer = LocalPlayer.PlayerScripts:FindFirstChild("OptimizerClientActor")
                if optimizer and optimizer.SendMessage then optimizer:SendMessage("Optimize", true) end
                Env.reducing = false
            end)
        end)
    end
    local FPSBoostHookDone = false
    local function ApplyFPSBoostToNew(obj)
        if not _G.FPSBoost then
            return
        end
        local ok = pcall(function()
            if obj:IsA("ParticleEmitter") then
                if obj.Parent and obj.Parent.Name ~= "ElectricFire" then
                    obj.Enabled = false
                    obj.Lifetime = NumberRange.new(0)
                end
            elseif obj:IsA("Trail") then
                obj.Lifetime = NumberRange.new(0)
            elseif obj:IsA("Decal") or obj:IsA("Texture") then
                obj.Transparency = 1
            elseif obj:IsA("Fire") or obj:IsA("SpotLight") or obj:IsA("Smoke") then
                obj.Enabled = false
            elseif obj:IsA("Explosion") then
                obj.BlastPressure, obj.BlastRadius = 1, 1
            elseif obj:IsA("BasePart") or obj:IsA("UnionOperation")
                or obj:IsA("CornerWedgePart") or obj:IsA("TrussPart") then
                obj.Material = Enum.Material.SmoothPlastic
                obj.Reflectance = 0
            end
        end)
        return ok
    end
    PerformanceAPI.ApplyFPSBoost = function()
        task.spawn(function()
            pcall(function()
                local lighting = game:GetService("Lighting")
                local atmosphere = lighting:FindFirstChild("BaseAtmosphere")
                if atmosphere then atmosphere:Destroy() end
            end)
            pcall(function() settings().Rendering.QualityLevel = "Level01" end)
            pcall(function()
                local terrain = workspace.Terrain
                if terrain then
                    terrain.WaterWaveSize = 0
                    terrain.WaterWaveSpeed = 0
                    terrain.WaterReflectance = 0
                    terrain.WaterTransparency = 0
                end
            end)
            pcall(function()
                local lighting = game:GetService("Lighting")
                lighting.GlobalShadows = false
                for _, item in ipairs(lighting:GetDescendants()) do
                    if item:IsA("BlurEffect") then
                        item.Enabled = false
                    end
                end
            end)
            pcall(function()
                local sliceStarted = os.clock()
                for _, item in ipairs(game:GetDescendants()) do
                    if item:IsA("ParticleEmitter") or item:IsA("Trail") then
                        item.Lifetime = NumberRange.new(0)
                    elseif item:IsA("Decal") or item:IsA("Texture") then
                        item.Transparency = 1
                    elseif item:IsA("Fire") or item:IsA("SpotLight") or item:IsA("Smoke") then
                        item.Enabled = false
                    elseif item:IsA("Explosion") then
                        item.BlastPressure, item.BlastRadius = 1, 1
                    elseif item:IsA("BasePart") or item:IsA("UnionOperation") or item:IsA("CornerWedgePart") or item:IsA("TrussPart") then
                        item.Reflectance = 0
                    end
                    if os.clock() - sliceStarted >= 0.0042 then task.wait(); sliceStarted = os.clock() end
                end
            end)
            pcall(function()
                local replicated = game:GetService("ReplicatedStorage")
                local smooth = Enum.Material.SmoothPlastic
                local sliceStarted = os.clock()
                local folders = {}
                local map = workspace:FindFirstChild("Map")
                if map then folders[#folders + 1] = map end
                local unloaded = replicated:FindFirstChild("Unloaded")
                if unloaded then folders[#folders + 1] = unloaded end
                for _, folder in ipairs(folders) do
                    for _, item in ipairs(folder:GetDescendants()) do
                        if item:IsA("BasePart") then
                            item.Material = smooth
                        elseif item:IsA("Texture") and not item:GetAttribute("Offset") then
                            item:Destroy()
                        end
                        if os.clock() - sliceStarted >= 0.0042 then task.wait(); sliceStarted = os.clock() end
                    end
                end
            end)
            pcall(function()
                local optimizer = LocalPlayer.PlayerScripts:FindFirstChild("OptimizerClientActor")
                if optimizer and optimizer.SendMessage then optimizer:SendMessage("Optimize", true) end
            end)
            if FPSBoostHookDone then
                return
            end
            FPSBoostHookDone = true
            task.spawn(function()
                local worldOrigin = workspace:FindFirstChild("_WorldOrigin")
                local waited = 0
                while not worldOrigin and waited < 60 do
                    task.wait(1)
                    waited = waited + 1
                    worldOrigin = workspace:FindFirstChild("_WorldOrigin")
                end
                if not worldOrigin then
                    return
                end
                worldOrigin.DescendantAdded:Connect(function(obj)
                    pcall(ApplyFPSBoostToNew, obj)
                end)
            end)
        end)
    end
end
local SailNoclipOn = false
local function ApplySailNoclip(on)
    local boats = workspace:FindFirstChild("Boats")
    if boats then
        for _, boat in ipairs(boats:GetChildren()) do
            for _, d in ipairs(boat:GetDescendants()) do
                if d:IsA("BasePart") then
                    d.CanCollide = not on
                end
            end
        end
    end
    for _, p in ipairs(Players:GetPlayers()) do
        local char = p.Character
        if char then
            for _, d in ipairs(char:GetDescendants()) do
                if d:IsA("BasePart") then
                    if on then
                        d.CanCollide = false
                    else
                        d.CanCollide = d.Name == "HumanoidRootPart"
                            or d.Name:find("LowerTorso") ~= nil
                            or d.Name:find("UpperTorso") ~= nil
                    end
                end
            end
        end
    end
end
RestoreWallClip = function()
    pcall(ApplySailNoclip, false)
end
_G.RJR_ResetMapNoclipState = function()
    RestoreWallClip()
end
task.spawn(function()
    while task.wait(0.1) do
        local on = (os.clock() - LastSailAt) < 0.5
        if on or SailNoclipOn then
            pcall(ApplySailNoclip, on)
        end
        SailNoclipOn = on
    end
end)
local RJR_SilentAimTarget = (function()
    local TargetPos, At = nil, 0
    local function RootOf(model)
        if not model then
            return nil
        end
        return model:FindFirstChild("HumanoidRootPart")
            or model:FindFirstChild("RootPart")
            or model.PrimaryPart
            or model:FindFirstChild("Head")
            or model:FindFirstChildWhichIsA("BasePart")
    end
    local function AimPoint(model, root)
        if not model or not model.Parent then
            return nil
        end
        local seg = model:FindFirstChild("Leviathan Segment") or model:FindFirstChild("Hitbox")
        if seg and seg:IsA("BasePart") then
            return seg.Position
        end
        if not root then
            return nil
        end
        if model:FindFirstChild("Engine") then
            return Vector3.new(root.Position.X, -58, root.Position.Z)
        end
        return Vector3.new(root.Position.X, math.max(root.Position.Y, 40), root.Position.Z)
    end
    return function()
        local now = os.clock()
        if now - At < 0.2 then
            return TargetPos
        end
        At = now
        TargetPos = nil
        local _, myHRP = GetCharacterParts()
        if not myHRP then
            return nil
        end
        local myPos = myHRP.Position
        local best, bestDist = nil, nil
        local function Consider(pos)
            if not pos then
                return
            end
            local d = (pos - myPos).Magnitude
            if bestDist == nil or d < bestDist then
                best, bestDist = pos, d
            end
        end
        local lvModel, lvPart = SeaAPI.Leviathan_Find()
        if lvModel then
            Consider(AimPoint(lvModel, lvPart))
        end
        if AttackModel and AttackModel.Parent then
            Consider(AimPoint(AttackModel, RootOf(AttackModel)))
        end
        local Mob, Root = SeaAPI.Sea_Mob(1500)
        if Mob then
            Consider(AimPoint(Mob, Root))
        end
        TargetPos = best
        return best
    end
end)()
RunService:BindToRenderStep("RJR_AimCamera", Enum.RenderPriority.Camera.Value + 1, function()
    if not (_G.AutoLeviathanFull and _G.SilentAim and AttackModel) then
        return
    end
    local aimPos = RJR_SilentAimTarget()
    local cam = workspace.CurrentCamera
    local _, hrpAim = GetCharacterParts()
    if not aimPos or not cam or not hrpAim then
        return
    end
    local flat = Vector3.new(aimPos.X - hrpAim.Position.X, 0, aimPos.Z - hrpAim.Position.Z)
    if flat.Magnitude < 1 then
        return
    end
    local dir = flat.Unit
    pcall(function()
        cam.CFrame = CFrame.lookAt(hrpAim.Position - dir * 13 + Vector3.new(0, 7, 0),
            hrpAim.Position + dir * 30 + Vector3.new(0, 3, 0))
    end)
end)
pcall(function()
    local mt = getrawmetatable(game)
    local oldNamecall = mt.__namecall
    setreadonly(mt, false)
    mt.__namecall = newcclosure(function(self, ...)
        local method = getnamecallmethod()
        if method == "FireServer" or method == "InvokeServer" then
            if _G.AutoLeviathanFull and _G.SilentAim and
                (tostring(self) == "RemoteEvent" or tostring(self) == "CommE") then
                local aimPos = RJR_SilentAimTarget()
                local _, myHRP = GetCharacterParts()
                if aimPos and myHRP then
                    local args = {...}
                    local toTarget = aimPos - myHRP.Position
                    local redirected = false
                    for i, v in pairs(args) do
                        if typeof(v) == "Vector3" then
                            if v.Magnitude > 500 then
                                args[i] = aimPos
                            elseif toTarget.Magnitude > 0.1 then
                                args[i] = toTarget.Unit * math.max(v.Magnitude, 1)
                            end
                            redirected = true
                        end
                    end
                    if redirected then
                        return oldNamecall(self, unpack(args))
                    end
                end
            end
        end
        return oldNamecall(self, ...)
    end)
    setreadonly(mt, true)
end)
local function Update_Character()
    Character = LocalPlayer.Character
    HD = Character and (Character:FindFirstChild("Humanoid") or Character:WaitForChild("Humanoid"))
    HRP = Character and (Character:FindFirstChild("HumanoidRootPart") or Character:WaitForChild("HumanoidRootPart"))
end
LocalPlayer.CharacterAdded:Connect(function()
    if _G.AutoLeviathanFull and _G.Mode == "Capitán" then
        pcall(function()
            local boats = workspace:FindFirstChild("Boats")
            if boats then
                local Marked = 0
                for _, boat in ipairs(boats:GetChildren()) do
                    if IsBeastHunterBoat(boat) and BoatOwnerMatch(boat, LocalPlayer) then
                        _G.RJR_AbandonedBoats[boat] = true
                        Marked = Marked + 1
                    end
                end
                if Marked > 0 then
                    print("[Leviathan] El capitán murió: abandonados " .. Marked .. " barcos viejos, pendientes de recompra")
                end
            end
        end)
    end
    task.wait(1)
    Update_Character()
    task.wait(2)
    Haki_Auto()
end)
LocalPlayer.CharacterRemoving:Connect(function()
    Character = nil
    HD = nil
    HRP = nil
    NoclipOn = false
    LastNoclipApply = 0
end)
local CraftStatus = "Desactivado"
local CraftQualityList = {
    { Key = "CommonScroll", Label = "Common Scroll" },
    { Key = "RareScroll", Label = "Rare Scroll" },
    { Key = "LegendaryScroll", Label = "Legendary Scroll" },
    { Key = "MythicalScroll", Label = "Mythical Scroll" },
}
local CraftRecipesCache = nil
local function GetCraftRecipes()
    if not CraftRecipesCache then
        local ok, r = pcall(function()
            return require(RS.Modules.Data.CraftingRecipes)
        end)
        if ok then
            CraftRecipesCache = r
        end
    end
    return CraftRecipesCache
end
local function GetCraftData()
    local RF = RS.Modules and RS.Modules:FindFirstChild("Net") and RS.Modules.Net:FindFirstChild("RF/GetCraftPlayerData")
    if not RF then
        return nil, nil
    end
    local ok, data = pcall(function()
        return RF:InvokeServer()
    end)
    if ok and type(data) == "table" then
        return data.EtcItems, data.CraftProgression
    end
    return nil, nil
end
local function CheckCraftRecipe(r, Etc, Prog)
    for k, v in pairs(r.ProgressionRequirement or {}) do
        if (Prog[k] or 0) < v then
            return false, TranslateStatus("Falta progreso " .. k .. " (" .. (Prog[k] or 0) .. "/" .. v .. ")")
        end
    end
    for k, v in pairs(r.Ingredients) do
        if type(k) == "string" then
            if (Etc[k] or 0) < v then
                return false, TranslateStatus("Falta " .. k .. " (" .. (Etc[k] or 0) .. "/" .. v .. ")")
            end
        end
    end
    return true
end
local function TryCraft(key)
    local RF = RS.Modules and RS.Modules:FindFirstChild("Net") and RS.Modules.Net:FindFirstChild("RF/Craft")
    if not RF then
        return
    end
    pcall(function()
        RF:InvokeServer("Craft", key, 1, {})
    end)
end
task.spawn(function()
    while true do
        task.wait(5)
        local Q = _G.CraftQuality
        if not _G.AutoCraftScrolls or Q == nil or Q == "None" then
            if CraftStatus ~= T("craft.status.none") then
                CraftStatus = T("craft.status.none")
            end
        else
            pcall(function()
                local Etc, Prog = GetCraftData()
                local Recipes = GetCraftRecipes()
                if not Etc or not Prog or not Recipes then
                    CraftStatus = T("craft.status.error")
                    return
                end
                local target
                for _, c in ipairs(CraftQualityList) do
                    if c.Label == Q then
                        target = c
                        break
                    end
                end
                if not target then
                    return
                end
                local r = Recipes[target.Key]
                if not r then
                    CraftStatus = TranslateStatus("Receta no encontrada: " .. target.Key)
                    return
                end
                local okC, miss = CheckCraftRecipe(r, Etc, Prog)
                if okC then
                    TryCraft(target.Key)
                    CraftStatus = TranslateStatus(target.Label .. ": fabricado")
                else
                    CraftStatus = TranslateStatus(target.Label .. ": " .. miss)
                end
            end)
        end
    end
end)
local FruitsBlackList = {}
local LastRandomFruitAt = 0
task.spawn(function()
    while true do
        task.wait(0.5)
        if _G.AutoRandomFruit and HRP and HD and HD.Health > 0 then
            if os.clock() - LastRandomFruitAt >= 60 then
                LastRandomFruitAt = os.clock()
                pcall(function()
                    CommF:InvokeServer("Check", "DLCBoxData")
                    CommF:InvokeServer("Cousin", "DLCBoxData")
                end)
            end
        end
    end
end)
task.spawn(function()
    while task.wait(1) do
        if _G.AutoStoreFruits and HRP then
            local Containers = {LocalPlayer.Backpack, Character}
            for _, container in ipairs(Containers) do
                if container then
                    for _, k in ipairs(container:GetChildren()) do
                        if k:IsA("Tool") and string.find(k.Name, "Fruit", 1, true)
                            and not FruitsBlackList[k:GetAttribute("OriginalName")] then
                            local ok, result = pcall(function()
                                return CommF:InvokeServer("StoreFruit", k:GetAttribute("OriginalName"), k)
                            end)
                            if ok and result == 1 then
                                FruitsBlackList[k:GetAttribute("OriginalName")] = true
                            end
                        end
                    end
                end
            end
        end
    end
end)
local _ = (function()
do
    local LegacyCaptain = "\229\188\128\232\136\185"
    local LegacyFollower = "\232\183\159\233\154\143"
    if _G.Mode == LegacyCaptain then
        _G.Mode = "Capitán"
    elseif _G.Mode == LegacyFollower then
        _G.Mode = "Seguidor"
    end
end
local Fluent = loadstring(game:HttpGet("https://github.com/dawid-scripts/Fluent/releases/latest/download/main.lua"))()
local SaveManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/SaveManager.lua"))()
local InterfaceManager = loadstring(game:HttpGet("https://raw.githubusercontent.com/dawid-scripts/Fluent/master/Addons/InterfaceManager.lua"))()
local LANGUAGE_LABELS = _G.RJR_LanguageLabels or { "English", "Español", "中文" }
local function NormalizeLanguage(value)
    local norm = _G.RJR_NormalizeLanguage
    if norm then
        return norm(value)
    end
    return value
end
_G.Language = NormalizeLanguage(_G.Language) or "English"
local Window = Fluent:CreateWindow({
    Title = "RJR Hub | Auto Leviathan",
    SubTitle = "by Kismile",
    TabWidth = 160,
    Size = UDim2.fromOffset(606, 503),
    Acrylic = false,
    Theme = "Dark",
    MinimizeKey = Enum.KeyCode.G,
})
local InputService = game:GetService("UserInputService")
local IsMobile = InputService.TouchEnabled and not InputService.KeyboardEnabled
do
    local BASE_W, BASE_H = 606, 503
    local MARGIN = 0.95
    local function FitWindowToViewport()
        local root = Window and Window.Root
        if not (root and root:IsA("GuiObject")) then
            return
        end
        local camera = workspace.CurrentCamera
        if not camera then
            task.defer(function()
                task.wait(0.5)
                FitWindowToViewport()
            end)
            return
        end
        local viewport = camera.ViewportSize
        if not viewport or viewport.X <= 0 or viewport.Y <= 0 then
            return
        end
        local function FitAxis(base, viewportSize, fluentMin)
            local target = math.min(base, viewportSize * MARGIN)
            return math.max(target, math.min(fluentMin, viewportSize))
        end
        local width = math.floor(FitAxis(BASE_W, viewport.X, 470))
        local height = math.floor(FitAxis(BASE_H, viewport.Y, 380))
        local size = UDim2.fromOffset(width, height)
        local position = UDim2.fromOffset(
            math.floor((viewport.X - width) / 2),
            math.floor((viewport.Y - height) / 2)
        )
        root.Size = size
        root.Position = position
        Window.Size = size
        Window.Position = position
    end
    FitWindowToViewport()
    if IsMobile then
        local camera = workspace.CurrentCamera
        if camera then
            local lastX, lastY = camera.ViewportSize.X, camera.ViewportSize.Y
            camera:GetPropertyChangedSignal("ViewportSize"):Connect(function()
                local viewport = camera.ViewportSize
                if viewport.X == lastX and viewport.Y == lastY then
                    return
                end
                lastX, lastY = viewport.X, viewport.Y
                if Window.Maximized then
                    return
                end
                FitWindowToViewport()
            end)
        end
    end
end
local Tabs = {
    Status   = Window:AddTab({ Title = T("tab.status"), Icon = "anchor" }),
    Combat   = Window:AddTab({ Title = T("tab.combat"), Icon = "swords" }),
    Perf     = Window:AddTab({ Title = T("tab.perf"), Icon = "activity" }),
    Extra    = Window:AddTab({ Title = T("tab.craft"), Icon = "package" }),
    Webhook  = Window:AddTab({ Title = T("tab.webhook"), Icon = "link" }),
    Config   = Window:AddTab({ Title = T("tab.config"), Icon = "settings" }),
    Announce = Window:AddTab({ Title = T("tab.announcement"), Icon = "megaphone" }),
}
local function SendNotify(title, content)
    pcall(function()
        Fluent:Notify({
            Title = title,
            Content = content,
            Duration = 3,
        })
    end)
end
local SectionKeys = {}
local ButtonKeys = {}
local ParagraphKeys = {}
local TabKeys = {
    { tab = Tabs.Status, key = "tab.status" },
    { tab = Tabs.Combat, key = "tab.combat" },
    { tab = Tabs.Perf, key = "tab.perf" },
    { tab = Tabs.Extra, key = "tab.craft" },
    { tab = Tabs.Webhook, key = "tab.webhook" },
    { tab = Tabs.Config, key = "tab.config" },
    { tab = Tabs.Announce, key = "tab.announcement" },
}
local function SetSectionTitle(section, key)
    local root = section and section.Container and section.Container.Parent
    local label = root and root:FindFirstChildOfClass("TextLabel")
    if label then
        label.Text = T(key)
    end
end
local function SetTabTitle(tab, key)
    local label = tab and tab.Frame and tab.Frame:FindFirstChildOfClass("TextLabel")
    if label then
        label.Text = T(key)
    end
end
local ApplyLanguage
local StatusPara = Tabs.Status:AddParagraph({
    Title = T("status.current"),
    Content = T("notstarted"),
})
ParagraphKeys[#ParagraphKeys + 1] = { element = StatusPara, title = "status.current" }
local DetailPara = Tabs.Status:AddParagraph({
    Title = T("status.detail"),
    Content = T("notstarted"),
})
ParagraphKeys[#ParagraphKeys + 1] = { element = DetailPara, title = "status.detail" }
local TargetPara = Tabs.Status:AddParagraph({
    Title = T("status.target"),
    Content = T("notstarted"),
})
ParagraphKeys[#ParagraphKeys + 1] = { element = TargetPara, title = "status.target" }
task.spawn(function()
    local lastStatus, lastDetail, lastTarget = nil, nil, nil
    while task.wait(1) do
        pcall(function()
            if StatusText ~= lastStatus then
                lastStatus = StatusText
                StatusPara:SetDesc(StatusText)
            end
            local detail = GetStatusDetails()
            if detail ~= lastDetail then
                lastDetail = detail
                DetailPara:SetDesc(detail)
            end
            local target = GetTargetStatus()
            if target ~= lastTarget then
                lastTarget = target
                TargetPara:SetDesc(target)
            end
        end)
    end
end)
local playerListLocked = false
local huntFightLocked = false
local huntSelectLocked = false
local rjrAutoFullLocked = false
local SuppressModeNotify = false
local LastLockNotice = 0
local function NotifyLocked(key)
    if os.clock() - LastLockNotice < 2 then
        return
    end
    LastLockNotice = os.clock()
    SendNotify(T("notify.locked.title"), T(key))
end
local SuppressLockCallback = false
local function RevertLockedOption(option, value)
    if not option then
        return
    end
    SuppressLockCallback = true
    pcall(option.SetValue, option, value)
    SuppressLockCallback = false
end
local function UpdateModeLocks()
    local isCaptain = _G.Mode == "Capitán"
    playerListLocked = isCaptain
    huntFightLocked = not isCaptain
    huntSelectLocked = not isCaptain
end
local ModeSection = Tabs.Status:AddSection(T("sec.mode"))
SectionKeys[#SectionKeys + 1] = { element = ModeSection, key = "sec.mode" }
local ModeDropdown = ModeSection:AddDropdown("mode.select", {
    Title = T("mode.select"),
    Values = { T("mode.captain"), T("mode.follower") },
    Default = ModeDisplay(),
    Multi = false,
    Callback = function(Value)
        _G.Mode = (Value == T("mode.captain")) and "Capitán" or "Seguidor"
        SaveConfig()
        UpdateModeLocks()
        if not SuppressModeNotify then
            if _G.Mode == "Capitán" then
                SendNotify(T("sec.mode"), T("notify.mode.captain"))
            else
                SendNotify(T("sec.mode"), T("notify.mode.follower"))
            end
        end
        if _G.AutoLeviathanFull then
            if _G.Mode == "Capitán" then
                StartCaptain()
            else
                StartFollower()
            end
            StatusText = T("status.on") .. " (" .. ModeDisplay() .. ")"
        end
    end,
})
local TeamSection = Tabs.Status:AddSection(T("sec.team"))
SectionKeys[#SectionKeys + 1] = { element = TeamSection, key = "sec.team" }
local PlayerListOptions = {}
local PlayerDropdown
local PushedPlayerList
local function SamePlayerList(a, b)
    if not a or not b or #a ~= #b then
        return false
    end
    for i = 1, #a do
        if a[i] ~= b[i] then
            return false
        end
    end
    return true
end
local function RefreshPlayerList()
    local list = {}
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer then
            table.insert(list, player.Name)
        end
    end
    table.sort(list)
    if #list == 0 then
        list = { "--" }
    end
    PlayerListOptions = list
    if PlayerDropdown and not SamePlayerList(PushedPlayerList, list) then
        PushedPlayerList = list
        pcall(function()
            PlayerDropdown:SetValues(list)
        end)
    end
    if not playerListLocked
        and (_G.FollowTarget == nil or _G.FollowTarget == "" or _G.FollowTarget == "--") then
        _G.FollowTarget = list[1] or ""
        if _G.FollowTarget == "--" then
            _G.FollowTarget = ""
        end
        if PlayerDropdown then
            pcall(function()
                PlayerDropdown:SetValue(_G.FollowTarget)
            end)
        end
        SaveConfig()
    end
end
PlayerDropdown = TeamSection:AddDropdown("follow.player", {
    Title = T("follow.player"),
    Values = PlayerListOptions,
    Default = nil,
    Multi = false,
    Callback = function(Value)
        if SuppressLockCallback then
            return
        end
        if playerListLocked then
            NotifyLocked("notify.locked.player")
            if _G.FollowTarget and _G.FollowTarget ~= "" then
                RevertLockedOption(PlayerDropdown, _G.FollowTarget)
            end
            return
        end
        _G.FollowTarget = Value or ""
        SaveConfig()
    end,
})
local RefreshButton = TeamSection:AddButton({
    Title = T("refresh.btn"),
    Callback = function()
        RefreshPlayerList()
        SendNotify(T("sec.team"), T("notify.players.refreshed"))
    end,
})
ButtonKeys[#ButtonKeys + 1] = { element = RefreshButton, key = "refresh.btn" }
task.spawn(function()
    while true do
        task.wait(5)
        pcall(RefreshPlayerList)
    end
end)
local TravelSection = Tabs.Status:AddSection(T("sec.travel"))
SectionKeys[#SectionKeys + 1] = { element = TravelSection, key = "sec.travel" }
TravelSection:AddInput("boat.speed", {
    Title = T("boat.speed"),
    Description = T("boat.speed.desc"),
    Default = tostring(_G.BoatSpeed),
    Placeholder = "250",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local speed = tonumber(Value)
        if speed then
            _G.BoatSpeed = math.clamp(speed, 50, 500)
            SaveConfig()
        end
    end,
})
TravelSection:AddInput("boat.height", {
    Title = T("boat.height"),
    Description = T("boat.height.desc"),
    Default = tostring(_G.BoatHeight),
    Placeholder = "150",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local height = tonumber(Value)
        if height then
            _G.BoatHeight = math.clamp(height, 30, 500)
            _G.BoatLockY = _G.BoatHeight
            SaveConfig()
        end
    end,
})
TravelSection:AddInput("player.tween.speed", {
    Title = T("player.tween.speed"),
    Description = T("player.tween.speed.desc"),
    Default = tostring(_G.PlayerTweenSpeed),
    Placeholder = "275",
    Numeric = true,
    Finished = false,
    Callback = function(Value)
        local speed = tonumber(Value)
        if speed then
            _G.PlayerTweenSpeed = math.clamp(speed, 50, 500)
            SaveConfig()
        end
    end,
})
TravelSection:AddToggle("cruise.return", {
    Title = T("cruise.return"),
    Description = T("cruise.return.desc"),
    Default = _G.CruiseReturn,
    Callback = function(State)
        _G.CruiseReturn = State
        SaveConfig()
    end,
})
local MainSection = Tabs.Status:AddSection(T("sec.main"))
SectionKeys[#SectionKeys + 1] = { element = MainSection, key = "sec.main" }
_G.RJR_AutoFullToggle = {
    Lock = function()
        rjrAutoFullLocked = true
    end,
    Unlock = function()
        rjrAutoFullLocked = false
    end,
}
local AutoFullToggle = MainSection:AddToggle("auto.full", {
    Title = T("auto.full"),
    Description = "",
    Default = _G.AutoLeviathanFull,
    Callback = function(State)
        if SuppressLockCallback then
            return
        end
        if rjrAutoFullLocked then
            NotifyLocked("notify.locked.solo")
            RevertLockedOption(AutoFullToggle, _G.AutoLeviathanFull)
            return
        end
        _G.AutoLeviathanFull = State
        StatusPrefix = ""
        if State then
            RefreshPlayerList()
            SaveConfig()
            if _G.Mode == "Capitán" then
                StartCaptain()
            else
                StartFollower()
            end
            StatusText = T("status.on") .. " (" .. ModeDisplay() .. ")"
            _G.RJR_BoatDeadArmed = true
            if _G.RJR_StartBoatDeadMonitor then
                _G.RJR_StartBoatDeadMonitor()
            end
        else
            StopTweenAll()
            _G.RJR_ResetMapNoclipState()
            StatusText = T("status.off")
        end
    end,
})
MainSection:AddToggle("solo.seafarm", {
    Title = T("solo.seafarm"),
    Description = T("solo.seafarm.desc"),
    Default = _G.SoloSeaFarm,
    Callback = function(State)
        _G.SoloSeaFarm = State
        SaveConfig()
        if State then
            _G.AutoLeviathanFull = true
            StatusPrefix = ""
            RefreshPlayerList()
            pcall(function()
                AutoFullToggle:SetValue(true)
            end)
            if _G.Mode == "Capitán" then
                StartCaptain()
            else
                StartFollower()
            end
            StatusText = T("status.on") .. " (" .. ModeDisplay() .. ")"
            if _G.RJR_AutoFullToggle and _G.RJR_AutoFullToggle.Lock then
                pcall(function()
                    _G.RJR_AutoFullToggle:Lock()
                end)
            end
            _G.RJR_BoatDeadArmed = true
            if _G.RJR_StartBoatDeadMonitor then
                _G.RJR_StartBoatDeadMonitor()
            end
        else
            StopTweenAll()
            _G.AutoLeviathanFull = false
            _G.RJR_ResetMapNoclipState()
            StatusPrefix = ""
            StatusText = T("status.stopped")
            if _G.RJR_AutoFullToggle and _G.RJR_AutoFullToggle.Unlock then
                pcall(function()
                    _G.RJR_AutoFullToggle:Unlock()
                end)
            end
        end
    end,
})
MainSection:AddToggle("respawn.rebuy", {
    Title = T("respawn.rebuy"),
    Description = T("respawn.rebuy.desc"),
    Default = _G.RespawnRebuy,
    Callback = function(State)
        _G.RespawnRebuy = State
        SaveConfig()
        if State and _G.AutoLeviathanFull then
            _G.RJR_BoatDeadArmed = true
            if _G.RJR_StartBoatDeadMonitor then
                _G.RJR_StartBoatDeadMonitor()
            end
        end
    end,
})
MainSection:AddToggle("info.ui", {
    Title = T("info.ui"),
    Description = T("info.ui.desc"),
    Default = _G.ShowInfoUI,
    Callback = function(State)
        _G.ShowInfoUI = State
        SaveConfig()
        if State then
            CreateInfoUI()
        else
            DestroyInfoUI()
        end
    end,
})
local StopButton = MainSection:AddButton({
    Title = T("stop.btn"),
    Callback = function()
        StopTweenAll()
        _G.AutoLeviathanFull = false
        _G.RJR_ResetMapNoclipState()
        StatusPrefix = ""
        StatusText = T("status.stopped")
        if _G.SoloSeaFarm then
            _G.SoloSeaFarm = false
            SaveConfig()
        end
        if _G.RJR_AutoFullToggle and _G.RJR_AutoFullToggle.Unlock then
            pcall(function()
                _G.RJR_AutoFullToggle:Unlock()
            end)
        end
        SendNotify(T("stop.btn"), T("status.stopped"))
    end,
})
ButtonKeys[#ButtonKeys + 1] = { element = StopButton, key = "stop.btn" }
do
    local function ArrayCopy(t)
        local out = {}
        for _, v in ipairs(CheckSkillTable(t)) do
            out[#out + 1] = v
        end
        return out
    end
    local CombatSection = Tabs.Combat:AddSection(T("sec.combat"))
    SectionKeys[#SectionKeys + 1] = { element = CombatSection, key = "sec.combat" }
    CombatSection:AddDropdown("sel.weapon", {
        Title = T("sel.weapon"),
        Values = { "Melee", "Sword", "Blox Fruit", "Gun" },
        Default = _G.SelectWeapon,
        Multi = false,
        Callback = function(Value)
            _G.SelectWeapon = Value
            SaveConfig()
        end,
    })
    CombatSection:AddDropdown("skill.melee", {
        Title = T("skill.melee"),
        Values = { "Z", "X", "C", "V" },
        Default = ArrayCopy(_G.SkillMelee),
        Multi = true,
        Callback = function(Value)
            _G.SkillMelee = CheckSkillTable(Value)
            SaveConfig()
        end,
    })
    CombatSection:AddDropdown("skill.sword", {
        Title = T("skill.sword"),
        Values = { "Z", "X" },
        Default = ArrayCopy(_G.SkillSword),
        Multi = true,
        Callback = function(Value)
            _G.SkillSword = CheckSkillTable(Value)
            SaveConfig()
        end,
    })
    CombatSection:AddDropdown("skill.fruit", {
        Title = T("skill.fruit"),
        Values = { "Z", "X", "C", "V", "F" },
        Default = ArrayCopy(_G.SkillFruit),
        Multi = true,
        Callback = function(Value)
            _G.SkillFruit = CheckSkillTable(Value)
            SaveConfig()
        end,
    })
    CombatSection:AddDropdown("skill.gun", {
        Title = T("skill.gun"),
        Values = { "Z", "X" },
        Default = ArrayCopy(_G.SkillGun),
        Multi = true,
        Callback = function(Value)
            _G.SkillGun = CheckSkillTable(Value)
            SaveConfig()
        end,
    })
    CombatSection:AddToggle("silent.aim", {
        Title = T("silent.aim"),
        Description = T("silent.aim.desc"),
        Default = _G.SilentAim,
        Callback = function(State)
            _G.SilentAim = State
            SaveConfig()
        end,
    })
    CombatSection:AddToggle("fast.attack", {
        Title = T("fast.attack"),
        Description = T("fast.attack.desc"),
        Default = _G.FastAttack,
        Callback = function(State)
            _G.FastAttack = State
            SaveConfig()
        end,
    })
    CombatSection:AddToggle("dragon.farm", {
        Title = T("dragon.farm"),
        Description = T("dragon.farm.desc"),
        Default = _G.DragonGunFarm,
        Callback = function(State)
            _G.DragonGunFarm = State
            SaveConfig()
            if State then
                SeaAPI.StartDragonAttack()
            end
        end,
    })
    CombatSection:AddToggle("dragon.leviathan", {
        Title = T("dragon.leviathan"),
        Description = T("dragon.leviathan.desc"),
        Default = _G.DragonGunLeviathan,
        Callback = function(State)
            _G.DragonGunLeviathan = State
            SaveConfig()
            if State then
                SeaAPI.InitDragon()
            end
        end,
    })
    CombatSection:AddToggle("remove.fog", {
        Title = T("remove.fog"),
        Description = T("remove.fog.desc"),
        Default = _G.RemoveFog,
        Callback = function(State)
            _G.RemoveFog = State
            SaveConfig()
            if State then
                DoRemoveFog()
            end
        end,
    })
    local HuntSection = Tabs.Combat:AddSection(T("sec.hunt"))
    SectionKeys[#SectionKeys + 1] = { element = HuntSection, key = "sec.hunt" }
    HuntSection:AddToggle("hunt.events", {
        Title = T("hunt.events"),
        Description = T("hunt.events.desc"),
        Default = _G.HuntFightEvents,
        Callback = function(State)
            if SuppressLockCallback then
                return
            end
            if huntFightLocked then
                NotifyLocked("notify.locked.hunt")
                RevertLockedOption(Fluent.Options["hunt.events"], _G.HuntFightEvents)
                return
            end
            _G.HuntFightEvents = State
            SaveConfig()
        end,
    })
    HuntSection:AddDropdown("hunt.select.events", {
        Title = T("hunt.select.events"),
        Description = T("hunt.select.events.desc"),
        Values = {
            "Shark",
            "Piranha",
            "Fish Crew Member",
            "Terrorshark",
            "Sea Beast",
            "Ghost Ship",
            "Pirate Brigade Ship",
            "Pirate Grand Brigade Ship",
            "Pirate Basic Ship",
        },
        Default = ArrayCopy(_G.HuntSelectEvents),
        Multi = true,
        Callback = function(Value)
            if SuppressLockCallback then
                return
            end
            if huntSelectLocked then
                NotifyLocked("notify.locked.hunt")
                local selection = {}
                for _, name in ipairs(CheckSkillTable(_G.HuntSelectEvents)) do
                    selection[name] = true
                end
                RevertLockedOption(Fluent.Options["hunt.select.events"], selection)
                return
            end
            _G.HuntSelectEvents = CheckSkillTable(Value)
            SaveConfig()
        end,
    })
end
do
    local PerfSection = Tabs.Perf:AddSection(T("sec.performance"))
    SectionKeys[#SectionKeys + 1] = { element = PerfSection, key = "sec.performance" }
    PerfSection:AddToggle("anti.draco", {
        Title = T("anti.draco"),
        Description = T("anti.draco.desc"),
        Default = _G.AntiDracoAura,
        Callback = function(State)
            _G.AntiDracoAura = State
            SaveConfig()
            if State then
                PerformanceAPI.ApplyAntiDracoAura()
            end
        end,
    })
    PerfSection:AddToggle("auto.fast", {
        Title = T("auto.fast"),
        Description = T("auto.fast.desc"),
        Default = _G.AutoFastMode,
        Callback = function(State)
            _G.AutoFastMode = State
            SaveConfig()
            if State then
                PerformanceAPI.ApplyAutoFastMode()
            end
        end,
    })
    PerfSection:AddToggle("fps.boost", {
        Title = T("fps.boost"),
        Description = T("fps.boost.desc"),
        Default = _G.FPSBoost,
        Callback = function(State)
            _G.FPSBoost = State
            SaveConfig()
            if State then
                PerformanceAPI.ApplyFPSBoost()
            end
        end,
    })
    local HakiSection = Tabs.Perf:AddSection(T("sec.haki"))
    SectionKeys[#SectionKeys + 1] = { element = HakiSection, key = "sec.haki" }
    HakiSection:AddToggle("auto.buso", {
        Title = T("auto.buso"),
        Description = "",
        Default = _G.AutoBuso,
        Callback = function(State)
            _G.AutoBuso = State
            SaveConfig()
        end,
    })
    HakiSection:AddToggle("auto.ken", {
        Title = T("auto.ken"),
        Description = T("auto.ken.desc"),
        Default = _G.AutoKen,
        Callback = function(State)
            _G.AutoKen = State
            SaveConfig()
        end,
    })
    HakiSection:AddToggle("auto.v3", {
        Title = T("auto.v3"),
        Description = T("auto.v3.desc"),
        Default = _G.AutoV3,
        Callback = function(State)
            _G.AutoV3 = State
            SaveConfig()
        end,
    })
    HakiSection:AddToggle("auto.v4", {
        Title = T("auto.v4"),
        Description = T("auto.v4.desc"),
        Default = _G.AutoV4,
        Callback = function(State)
            _G.AutoV4 = State
            SaveConfig()
        end,
    })
end
do
    local CraftPara = Tabs.Extra:AddParagraph({
        Title = T("craft.status"),
        Content = T("notstarted"),
    })
    ParagraphKeys[#ParagraphKeys + 1] = { element = CraftPara, title = "craft.status" }
    task.spawn(function()
        local lastCraft = nil
        while task.wait(1) do
            pcall(function()
                if CraftStatus ~= lastCraft then
                    lastCraft = CraftStatus
                    CraftPara:SetDesc(CraftStatus)
                end
            end)
        end
    end)
    Tabs.Extra:AddToggle("craft.auto", {
        Title = T("craft.auto"),
        Description = T("craft.auto.desc"),
        Default = _G.AutoCraftScrolls,
        Callback = function(State)
            _G.AutoCraftScrolls = State
            SaveConfig()
        end,
    })
    Tabs.Extra:AddDropdown("craft.quality", {
        Title = T("craft.quality"),
        Description = T("craft.quality.desc"),
        Values = { "None", "Common Scroll", "Rare Scroll", "Legendary Scroll", "Mythical Scroll" },
        Default = _G.CraftQuality,
        Multi = false,
        Callback = function(Value)
            _G.CraftQuality = Value or "None"
            SaveConfig()
        end,
    })
    Tabs.Extra:AddToggle("craft.roll", {
        Title = T("craft.roll"),
        Description = "",
        Default = _G.AutoRandomFruit,
        Callback = function(State)
            _G.AutoRandomFruit = State
            SaveConfig()
        end,
    })
    Tabs.Extra:AddToggle("craft.store", {
        Title = T("craft.store"),
        Description = "",
        Default = _G.AutoStoreFruits,
        Callback = function(State)
            _G.AutoStoreFruits = State
            SaveConfig()
        end,
    })
    local ResetButton = Tabs.Extra:AddButton({
        Title = T("reset.data"),
        Callback = function()
            local args = {
                "BlackbeardReward",
                "Refund",
                "2"
            }
            pcall(function()
                local remotes = RS:FindFirstChild("Remotes")
                local CommF2 = remotes and remotes:FindFirstChild("CommF_")
                if CommF2 then
                    CommF2:InvokeServer(unpack(args))
                end
            end)
        end,
    })
    ButtonKeys[#ButtonKeys + 1] = { element = ResetButton, key = "reset.data" }
end
do
    local WebhookSendLock = false
    local AvatarCache = {}
    local function GetAvatarImage(userId)
        userId = tostring(userId)
        if AvatarCache[userId] then
            return AvatarCache[userId]
        end
        local fallback = "https://thumbnails.roblox.com/v1/users/avatar?userIds=" .. userId
            .. "&size=420x420&format=Png&isCircular=false"
        local avatarReq = (syn and syn.request) or (http and http.request) or http_request or request
        local found
        if avatarReq then
            local ok, resp = pcall(avatarReq, {
                Url = fallback,
                Method = "GET",
            })
            if ok and resp and (resp.StatusCode or resp.statusCode) == 200 then
                local body = resp.Body or resp.body or ""
                local okDec, data = pcall(HttpService.JSONDecode, HttpService, body)
                if okDec and type(data) == "table" and data.data and type(data.data[1]) == "table" then
                    found = data.data[1].imageUrl
                end
            end
        end
        if not found then
            found = fallback
        end
        AvatarCache[userId] = found
        return found
    end
    local function SendWebhook(content, title, onDone, mentionEveryone)
        if _G.WebhookURL == nil or _G.WebhookURL == "" then
            if onDone then onDone(false) end
            return false
        end
        if WebhookSendLock then
            if onDone then onDone(false) end
            return false
        end
        local req = (syn and syn.request) or (http and http.request) or http_request or request
        local httpPost = http and http.post
        if not req and not httpPost then
            if onDone then onDone(false) end
            return false, "no request api"
        end
        WebhookSendLock = true
        task.spawn(function()
            local ok = false
            pcall(function()
                local HttpServiceLocal = game:GetService("HttpService")
                local payload, headers
                headers = { ["Content-Type"] = "application/json" }
                do
                    local titleStr = title or "Auto Leviathan"
                    local embedColor
                    if titleStr:find("Leviathan", 1, true) then
                        embedColor = 0x9C27B0
                    elseif titleStr:find("Corazón", 1, true) or titleStr:find("Heart", 1, true) then
                        embedColor = 0x1E88E5
                    elseif titleStr:find("Soborno", 1, true) or titleStr:find("Bribe", 1, true) then
                        embedColor = 0xFB8C00
                    elseif titleStr:find("Jugadores", 1, true) or titleStr:find("Players", 1, true) then
                        embedColor = 0xE53935
                    else
                        embedColor = 0x32CD32
                    end
                    local fields = {}
                    local descriptions = {}
                    for line in (content or ""):gmatch("[^\n]+") do
                        local k, v = line:match("^(.-):%s*(.*)$")
                        if k and v and v ~= "" then
                            fields[#fields + 1] = {
                                name = k:gsub("^%s*(.-)%s*$", "%1"),
                                value = v:gsub("^%s*(.-)%s*$", "%1"),
                                inline = true,
                            }
                        else
                            descriptions[#descriptions + 1] = line
                        end
                    end
                    if #fields == 0 then
                        fields = { { name = " ", value = table.concat(descriptions, "\n"), inline = false } }
                    end
                    local userFields = {
                        { name = T("wh.field.user"), value = LocalPlayer.Name, inline = true },
                        { name = T("wh.field.display"), value = LocalPlayer.DisplayName, inline = true },
                        { name = T("wh.field.uid"), value = string.format("[%d](https://www.roblox.com/users/%d/profile)", LocalPlayer.UserId, LocalPlayer.UserId), inline = true },
                    }
                    local finalFields = {}
                    for _, f in ipairs(fields) do
                        finalFields[#finalFields + 1] = f
                    end
                    for _, f in ipairs(userFields) do
                        finalFields[#finalFields + 1] = f
                    end
                    local SenderName = (_G.WebhookUsername and _G.WebhookUsername ~= "") and _G.WebhookUsername or "Auto Leviathan"
                    payload = {
                        username = SenderName,
                        avatar_url = GetAvatarImage(LocalPlayer.UserId),
                        embeds = {{
                            color = tonumber("0x" .. string.format("%X", embedColor)),
                            title = titleStr,
                            description = (#descriptions > 0) and table.concat(descriptions, "\n") or nil,
                            thumbnail = { url = GetAvatarImage(LocalPlayer.UserId) },
                            fields = finalFields,
                            footer = {
                                text = SenderName .. " · " .. os.date("%Y-%m-%d %H:%M:%S"),
                                icon_url = GetAvatarImage(LocalPlayer.UserId),
                            },
                        }}
                    }
                    if mentionEveryone then
                        payload.content = "@everyone"
                    end
                end
                local resp
                if httpPost and not req then
                    resp = httpPost(_G.WebhookURL, HttpServiceLocal:JSONEncode(payload), headers)
                else
                    resp = req({
                        Url = _G.WebhookURL,
                        Method = "POST",
                        Headers = headers,
                        Body = HttpServiceLocal:JSONEncode(payload)
                    })
                end
                local code = resp and (resp.StatusCode or resp.statusCode or resp.Status or resp.status)
                ok = code == nil or code == 200 or code == 204
                if not ok then
                    print("[Webhook] envio fallido HTTP " .. tostring(code))
                end
            end)
            WebhookSendLock = false
            if onDone then
                onDone(ok)
            end
        end)
        return true
    end
    local WebhookStatusPara = Tabs.Webhook:AddParagraph({
        Title = T("webhook.status"),
        Content = T("webhook.off"),
    })
    ParagraphKeys[#ParagraphKeys + 1] = { element = WebhookStatusPara, title = "webhook.status" }
    local function SendWebhookUI(content, title, mentionEveryone)
        local okCall, err = SendWebhook(content, title, function(ok)
            if ok then
                WebhookStatusPara:SetDesc(T("webhook.sent") .. os.date("%H:%M:%S"))
            else
                WebhookStatusPara:SetDesc(T("wh.sendfailed"))
            end
        end, mentionEveryone)
        if not okCall then
            WebhookStatusPara:SetDesc(T("wh.sendfailed") .. (err and (" (" .. tostring(err) .. ")") or ""))
        end
    end
    local function GetMaterialCounts()
        local Etc = GetCraftData()
        local ScaleT, HeartT, ScrollT = "0", "0", ""
        if Etc then
            for k, v in pairs(Etc) do
                if type(v) == "number" then
                    local key = tostring(k)
                    if key:find("Leviathan") ~= nil and key:find("Scale") ~= nil then
                        ScaleT = tostring(v)
                    elseif key:find("Leviathan") ~= nil and key:find("Heart") ~= nil then
                        HeartT = tostring(v)
                    elseif key:find("Scroll") ~= nil then
                        if ScrollT == "" then
                            ScrollT = key .. ": " .. tostring(v)
                        else
                            ScrollT = ScrollT .. ", " .. key .. ": " .. tostring(v)
                        end
                    end
                end
            end
        end
        return ScaleT, HeartT, ScrollT
    end
    local function BuildProgressMsg()
        local ScaleT, HeartT, ScrollT = GetMaterialCounts()
        return T("wh.bribe") .. ": " .. StatusText
            .. "\n" .. T("wh.material") .. ": Leviathan Scale: " .. ScaleT .. ", Leviathan Heart: " .. HeartT
            .. "\n" .. T("wh.scroll") .. ": " .. (ScrollT == "" and T("wh.none") or ScrollT)
            .. "\n" .. T("wh.crafted") .. ": " .. CraftStatus
    end
    Tabs.Webhook:AddInput("webhook.url", {
        Title = T("webhook.url"),
        Description = T("webhook.url.desc"),
        Default = _G.WebhookURL,
        Placeholder = "https://discord.com/api/webhooks/...",
        Finished = true,
        Callback = function(Text)
            _G.WebhookURL = tostring(Text or "")
            SaveConfig()
        end,
    })
    Tabs.Webhook:AddInput("webhook.username", {
        Title = T("webhook.username"),
        Description = T("webhook.username.desc"),
        Default = _G.WebhookUsername,
        Placeholder = "Auto Leviathan",
        Finished = true,
        Callback = function(Text)
            _G.WebhookUsername = tostring(Text or "")
            SaveConfig()
        end,
    })
    Tabs.Webhook:AddToggle("webhook.auto", {
        Title = T("webhook.auto"),
        Description = T("webhook.auto.desc"),
        Default = _G.AutoWebhook,
        Callback = function(State)
            _G.AutoWebhook = State
            SaveConfig()
        end,
    })
    Tabs.Webhook:AddInput("webhook.interval", {
        Title = T("webhook.interval"),
        Description = "",
        Default = tostring(_G.WebhookInterval or 60),
        Placeholder = "60",
        Numeric = true,
        Finished = false,
        Callback = function(Text)
            local n = tonumber(Text)
            if n and n > 0 then
                _G.WebhookInterval = math.floor(n)
                SaveConfig()
            end
        end,
    })
    Tabs.Webhook:AddToggle("webhook.send.progress", {
        Title = T("webhook.send.progress"),
        Description = T("webhook.send.progress.desc"),
        Default = _G.WebhookSendProgress,
        Callback = function(State)
            _G.WebhookSendProgress = State
            SaveConfig()
        end,
    })
    Tabs.Webhook:AddToggle("webhook.send.bribe", {
        Title = T("webhook.send.bribe"),
        Description = T("webhook.send.bribe.desc"),
        Default = _G.WebhookSendBribeReady,
        Callback = function(State)
            _G.WebhookSendBribeReady = State
            SaveConfig()
        end,
    })
    Tabs.Webhook:AddToggle("webhook.send.leviathan", {
        Title = T("webhook.send.leviathan"),
        Description = "",
        Default = _G.WebhookSendLeviathan,
        Callback = function(State)
            _G.WebhookSendLeviathan = State
            SaveConfig()
        end,
    })
    Tabs.Webhook:AddToggle("webhook.send.heartspawn", {
        Title = T("webhook.send.heartspawn"),
        Description = "",
        Default = _G.WebhookSendHeartSpawn,
        Callback = function(State)
            _G.WebhookSendHeartSpawn = State
            SaveConfig()
        end,
    })
    Tabs.Webhook:AddToggle("webhook.send.heartgot", {
        Title = T("webhook.send.heartgot"),
        Description = "",
        Default = _G.WebhookSendHeartGot,
        Callback = function(State)
            _G.WebhookSendHeartGot = State
            SaveConfig()
        end,
    })
    Tabs.Webhook:AddToggle("wh.lowplayers", {
        Title = T("wh.lowplayers"),
        Description = T("wh.lowplayers.desc"),
        Default = _G.WebhookSendLowPlayers,
        Callback = function(State)
            _G.WebhookSendLowPlayers = State
            SaveConfig()
        end,
    })
    local SendNowButton = Tabs.Webhook:AddButton({
        Title = T("webhook.send.now"),
        Callback = function()
            pcall(function()
                SendWebhookUI(BuildProgressMsg(), T("wh.title.manual"))
            end)
        end,
    })
    ButtonKeys[#ButtonKeys + 1] = { element = SendNowButton, key = "webhook.send.now" }
    task.spawn(function()
        while task.wait(1) do
            pcall(function()
                if _G.AutoWebhook then
                    WebhookStatusPara:SetDesc(T("webhook.sending"))
                else
                    WebhookStatusPara:SetDesc(T("webhook.off"))
                end
            end)
        end
    end)
    task.spawn(function()
        while true do
            task.wait(_G.WebhookInterval or 60)
            if _G.AutoWebhook and _G.WebhookSendProgress
                and _G.WebhookURL and _G.WebhookURL ~= "" then
                pcall(function()
                    SendWebhookUI(BuildProgressMsg(), T("wh.title.progress"))
                end)
            end
        end
    end)
    task.spawn(function()
        local PrevBribeReady = nil
        local PrevLeviathan = false
        local PrevHeartSpawn = false
        local PrevHeartGot = false
        local PrevLowPlayers = false
        while true do
            task.wait(1)
            if _G.AutoWebhook and _G.WebhookURL and _G.WebhookURL ~= "" then
                pcall(function()
                    if _G.WebhookSendBribeReady then
                        local S = GetBribeStatus()
                        local Ready = S ~= nil and S ~= -1 and S ~= 5
                        if Ready and PrevBribeReady == false then
                            SendWebhookUI(TranslateStatus("[Auto Leviathan] Soborno disponible - progreso " .. tostring(S) .. "/5"), T("wh.title.bribe"))
                        end
                        PrevBribeReady = Ready
                    end
                    if _G.WebhookSendLeviathan then
                        local NowLV = SeaAPI.Leviathan_SegmentsExist()
                        if NowLV and not PrevLeviathan then
                            SendWebhookUI(T("wh.msg.leviathan"), T("wh.title.leviathan"))
                        end
                        PrevLeviathan = NowLV
                    end
                    if _G.WebhookSendHeartSpawn then
                        local Map = workspace:FindFirstChild("Map")
                        local Heart = Map and Map:FindFirstChild("FrozenHeart")
                        local NowSpawn = Heart ~= nil
                        if NowSpawn and not PrevHeartSpawn then
                            SendWebhookUI(T("wh.msg.heartspawn"), T("wh.title.heartspawn"))
                        end
                        PrevHeartSpawn = NowSpawn
                    end
                    if _G.WebhookSendHeartGot then
                        local Map = workspace:FindFirstChild("Map")
                        local Heart = Map and Map:FindFirstChild("FrozenHeart")
                        local HP = Heart and GetHeartPos(Heart)
                        local Got = HP ~= nil and HP.Y < 110
                        if Got and not PrevHeartGot then
                            SendWebhookUI(T("wh.msg.heartgot"), T("wh.title.heartgot"))
                        end
                        PrevHeartGot = Got
                    end
                    if _G.WebhookSendLowPlayers then
                        local N = #Players:GetPlayers()
                        local Low = N < 5
                        if Low and not PrevLowPlayers then
                            SendWebhookUI(T("wh.lowplayers.msg") .. tostring(N) .. "\n" .. BuildProgressMsg(), T("wh.title.lowplayers"), true)
                        end
                        PrevLowPlayers = Low
                    end
                end)
            end
        end
    end)
end
do
    local LanguageSection = Tabs.Config:AddSection(T("language"))
    SectionKeys[#SectionKeys + 1] = { element = LanguageSection, key = "language" }
    LanguageSection:AddDropdown("language", {
        Title = T("language"),
        Description = T("language.desc"),
        Values = LANGUAGE_LABELS,
        Default = _G.Language,
        Multi = false,
        Callback = function(Value)
            local normalized = NormalizeLanguage(Value)
            if not normalized or normalized == _G.Language then
                return
            end
            _G.Language = normalized
            SaveConfig()
            ApplyLanguage()
            SendNotify(T("notify.title"), T("notify.lang.changed") .. ": " .. normalized)
        end,
    })
    pcall(function()
        SaveManager:SetLibrary(Fluent)
        InterfaceManager:SetLibrary(Fluent)
        SaveManager:IgnoreThemeSettings()
        SaveManager:SetIgnoreIndexes({})
        InterfaceManager.Settings.MenuKeybind = "G"
        InterfaceManager:SetFolder("AutoLeviathanES")
        SaveManager:SetFolder("AutoLeviathanES/configs")
        InterfaceManager:BuildInterfaceSection(Tabs.Config)
        SaveManager:BuildConfigSection(Tabs.Config)
        SaveManager:LoadAutoloadConfig()
    end)
    Tabs.Config:AddToggle("ui.floatingball", {
        Title = T("ui.floatingball"),
        Description = T("ui.floatingball.desc"),
        Default = _G.RJR_FloatingBall ~= false,
        Callback = function(Value)
            _G.RJR_FloatingBall = Value
            if _G.RJR_SetFloatingBall then
                pcall(_G.RJR_SetFloatingBall, Value)
            end
        end,
    })
end
do
    Tabs.Announce:AddParagraph({
        Title = T("ann.dc"),
        Content = "https://discord.gg/862SZpM7Qk",
    })
    local CopyButton = Tabs.Announce:AddButton({
        Title = T("ann.copy"),
        Callback = function()
            pcall(setclipboard, "https://discord.gg/862SZpM7Qk")
            SendNotify(T("notify.title"), T("ann.copied"))
        end,
    })
    ButtonKeys[#ButtonKeys + 1] = { element = CopyButton, key = "ann.copy" }
end
ApplyLanguage = function()
    for _, item in ipairs(TabKeys) do
        pcall(SetTabTitle, item.tab, item.key)
    end
    for _, item in ipairs(SectionKeys) do
        pcall(SetSectionTitle, item.element, item.key)
    end
    for idx, element in pairs(Fluent.Options) do
        if T(idx) ~= idx then
            pcall(function()
                element:SetTitle(T(idx))
            end)
            local descKey = idx .. ".desc"
            if T(descKey) ~= descKey then
                pcall(function()
                    element:SetDesc(T(descKey))
                end)
            end
        end
    end
    for _, item in ipairs(ParagraphKeys) do
        pcall(function()
            item.element:SetTitle(T(item.title))
        end)
    end
    for _, item in ipairs(ButtonKeys) do
        pcall(function()
            item.element:SetTitle(T(item.key))
        end)
    end
    if ModeDropdown then
        pcall(function()
            SuppressModeNotify = true
            ModeDropdown:SetValues({ T("mode.captain"), T("mode.follower") })
            ModeDropdown:SetValue(_G.Mode == "Capitán" and T("mode.captain") or T("mode.follower"))
            SuppressModeNotify = false
        end)
    end
    pcall(function()
        if _G.RJR_RefreshStatus then
            _G.RJR_RefreshStatus()
        end
    end)
end
do
    task.spawn(function()
        local UserInputService = game:GetService("UserInputService")
        do
            local containers = {}
            if gethui then
                local ok, hui = pcall(gethui)
                if ok and hui then
                    containers[#containers + 1] = hui
                end
            end
            pcall(function()
                containers[#containers + 1] = game:GetService("CoreGui")
            end)
            local playerGui = LocalPlayer:FindFirstChild("PlayerGui")
            if playerGui then
                containers[#containers + 1] = playerGui
            end
            for _, container in ipairs(containers) do
                local old = container:FindFirstChild("RJR_Hub_FloatingBall")
                if old then
                    pcall(function()
                        old:Destroy()
                    end)
                end
            end
        end
        local BallGui = Instance.new("ScreenGui")
        BallGui.Name = "RJR_Hub_FloatingBall"
        BallGui.ResetOnSpawn = false
        BallGui.IgnoreGuiInset = true
        BallGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
        BallGui.DisplayOrder = 999
        local ballEnabled = _G.RJR_FloatingBall
        if ballEnabled == nil then
            local option = Fluent.Options and Fluent.Options["ui.floatingball"]
            ballEnabled = option and option.Value
        end
        BallGui.Enabled = ballEnabled ~= false
        local Ball = Instance.new("TextButton")
        Ball.Name = "Orb"
        Ball.Size = UDim2.fromOffset(52, 52)
        if _G.RJR_BallPos then
            Ball.Position = UDim2.fromOffset(_G.RJR_BallPos.X, _G.RJR_BallPos.Y)
        else
            Ball.Position = UDim2.new(0, 16, 0.5, -26)
        end
        Ball.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
        Ball.BackgroundTransparency = 0.05
        Ball.AutoButtonColor = false
        Ball.Text = "RJR"
        Ball.Font = Enum.Font.GothamBold
        Ball.TextSize = 15
        Ball.TextColor3 = Color3.fromRGB(240, 240, 245)
        Ball.Parent = BallGui
        local Corner = Instance.new("UICorner")
        Corner.CornerRadius = UDim.new(1, 0)
        Corner.Parent = Ball
        local Stroke = Instance.new("UIStroke")
        Stroke.Thickness = 1.5
        Stroke.Color = Color3.fromRGB(96, 205, 255)
        Stroke.Transparency = 0.2
        Stroke.Parent = Ball
        local parentOk = pcall(function()
            BallGui.Parent = (gethui and gethui()) or game:GetService("CoreGui")
        end)
        if not parentOk or not BallGui.Parent then
            BallGui.Parent = LocalPlayer:WaitForChild("PlayerGui")
        end
        local function IsMenuOpen()
            local root = Window and Window.Root
            return root ~= nil and root.Visible == true
        end
        local function SyncBall()
            if IsMenuOpen() then
                Stroke.Color = Color3.fromRGB(96, 205, 255)
                Stroke.Transparency = 0.15
                Ball.BackgroundColor3 = Color3.fromRGB(22, 22, 26)
                Ball.TextColor3 = Color3.fromRGB(240, 240, 245)
            else
                Stroke.Color = Color3.fromRGB(84, 86, 96)
                Stroke.Transparency = 0.55
                Ball.BackgroundColor3 = Color3.fromRGB(14, 14, 17)
                Ball.TextColor3 = Color3.fromRGB(150, 152, 162)
            end
        end
        local function SetMenuOpen(open)
            local root = Window and Window.Root
            if not root then
                return
            end
            root.Visible = open
            Window.Minimized = not open
            SyncBall()
        end
        _G.RJR_SetFloatingBall = function(enabled)
            BallGui.Enabled = enabled == true
        end
        local dragging, moved, dragLast, movedDist = false, false, nil, 0
        Ball.InputBegan:Connect(function(input)
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = true
                moved = false
                dragLast = nil
                movedDist = 0
            end
        end)
        UserInputService.InputChanged:Connect(function(input)
            if not dragging then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
                local now = Vector2.new(input.Position.X, input.Position.Y)
                local step = Vector2.zero
                if dragLast then
                    step = now - dragLast
                end
                dragLast = now
                movedDist = movedDist + step.Magnitude
                if movedDist > 5 then
                    moved = true
                end
                if step.Magnitude > 0 then
                    local screen = BallGui.AbsoluteSize
                    if screen.X <= 0 or screen.Y <= 0 then
                        screen = workspace.CurrentCamera.ViewportSize
                    end
                    local size = Ball.AbsoluteSize
                    local pos = Ball.Position
                    local x = pos.X.Scale * screen.X + pos.X.Offset + step.X
                    local y = pos.Y.Scale * screen.Y + pos.Y.Offset + step.Y
                    Ball.Position = UDim2.fromOffset(
                        math.clamp(x, 0, math.max(0, screen.X - size.X)),
                        math.clamp(y, 0, math.max(0, screen.Y - size.Y))
                    )
                end
            end
        end)
        UserInputService.InputEnded:Connect(function(input)
            if not dragging then
                return
            end
            if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                dragging = false
                if moved then
                    local pos = Ball.Position
                    _G.RJR_BallPos = { X = pos.X.Offset, Y = pos.Y.Offset }
                else
                    SetMenuOpen(not IsMenuOpen())
                end
            end
        end)
        task.spawn(function()
            while BallGui.Parent do
                SyncBall()
                task.wait(0.25)
            end
        end)
        SyncBall()
    end)
end
UpdateModeLocks()
RefreshPlayerList()
Window:SelectTab(1)
ApplyLanguage()
task.defer(function()
    if _G.SoloSeaFarm and _G.RJR_AutoFullToggle and _G.RJR_AutoFullToggle.Lock then
        pcall(function()
            _G.RJR_AutoFullToggle:Lock()
        end)
    end
    if _G.DragonGunFarm then pcall(SeaAPI.StartDragonAttack) end
    if _G.RemoveFog then pcall(DoRemoveFog) end
    if _G.AntiDracoAura then pcall(PerformanceAPI.ApplyAntiDracoAura) end
    if _G.AutoFastMode then pcall(PerformanceAPI.ApplyAutoFastMode) end
    if _G.FPSBoost then pcall(PerformanceAPI.ApplyFPSBoost) end
end)
SendNotify(T("notify.title"), T("notify.ready"))
end)()
