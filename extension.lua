local scaler = dofile("./scripts/scaler.lua")

local dRatio = true

function math.round(number)
	return math.floor(number + 0.5)
end

function init(plugin)
    plugin:newCommand{id = "kcentroid",
        title = "K-Centroid Resize",
        group = "sprite_size",
        onenabled = function()
            return app.activeSprite ~= nil
        end,
        onclick = function()
            local width = app.activeSprite.selection.bounds.width
            local height = app.activeSprite.selection.bounds.height
            if app.activeSprite.selection.bounds == Rectangle(0,0,0,0) then
                width = app.activeCel.bounds.width
                height = app.activeCel.bounds.height
            end
            if app.activeImage.colorMode == ColorMode.RGB then
                local dialog = Dialog("K-Centroid Resize")
                dialog
                :separator{
                    text = "Pixels:"
                }
                :number{
                    id = "width",
                    label = "Width:",
                    text = tostring(width),
                    decimals = 0,
                    onchange = function()
                        dialog:modify{
                            id = "widthp",
                            text = tostring(math.min(100,(dialog.data.width/width)*100))
                        }
                        if dialog.data.ratio then
                            dialog:modify{
                                id = "heightp",
                                text = tostring(math.min(100,dialog.data.widthp))
                            }
                            dialog:modify{
                                id = "height",
                                text = tostring(math.min(height,math.round((dialog.data.heightp/100)*height)))
                            }
                        end
                    end
                }
                :number{
                    id = "height",
                    label = "Height:",
                    text = tostring(height),
                    decimals = 0,
                    onchange = function()
                        dialog:modify{
                            id = "heightp",
                            text = tostring(math.min(100,(dialog.data.height/height)*100))
                        }
                        if dialog.data.ratio then
                            dialog:modify{
                                id = "widthp",
                                text = tostring(math.min(100,dialog.data.heightp))
                            }
                            dialog:modify{
                                id = "width",
                                text = tostring(math.min(width,math.round((dialog.data.widthp/100)*width)))
                            }
                        end
                    end
                }
                :check{
                    id = "ratio",
                    text = "Lock Ratio",
                    selected = dRatio,
                    onclick = function()
                        if dialog.data.ratio then
                            dialog:modify{
                                id = "heightp",
                                text = tostring(math.min(100,dialog.data.widthp))
                            }
                            dialog:modify{
                                id = "height",
                                text = tostring(math.min(height,math.round((dialog.data.heightp/100)*height)))
                            }
                            dialog:modify{
                                id = "width",
                                text = tostring(math.min(width,math.round((dialog.data.widthp/100)*width)))
                            }
                        end
                    end
                }
                :separator{
                    text = "Percentage:"
                }
                :number{
                    id = "widthp",
                    label = "Width:",
                    text = tostring(100),
                    decimals = 4,
                    onchange = function()
                        dialog:modify{
                            id = "width",
                            text = tostring(math.min(width,math.round((dialog.data.widthp/100)*width)))
                        }
                        if dialog.data.ratio then
                            dialog:modify{
                                id = "heightp",
                                text = tostring(math.min(100,dialog.data.widthp))
                            }
                            dialog:modify{
                                id = "height",
                                text = tostring(math.min(height,math.round((dialog.data.heightp/100)*height)))
                            }
                        end
                    end
                }
                :number{
                    id = "heightp",
                    label = "Height:",
                    text = tostring(100),
                    decimals = 4,
                    onchange = function()
                        dialog:modify{
                            id = "height",
                            text = tostring(math.min(height,math.round((dialog.data.heightp/100)*height)))
                        }
                        if dialog.data.ratio then
                            dialog:modify{
                                id = "widthp",
                                text = tostring(math.min(100,dialog.data.heightp))
                            }
                            dialog:modify{
                                id = "width",
                                text = tostring(math.min(width,math.round((dialog.data.widthp/100)*width)))
                            }
                        end
                    end
                }
                :separator{
                    text = "K-Means:"
                }
                :slider{
                    id = "centroids",
                    label = "Centroids",
                    min = 2,
                    max = 16,
                    value = 2,
                }
                :slider{
                    id = "accuracy",
                    label = "Itterations",
                    min = 1,
                    max = 20,
                    value = 3,
                }
                :separator()
                :button{
                    text = "OK",
                    focus = true,
                    onclick = function()
                        dialog:modify{
                            id = "width",
                            text = tostring(math.min(width,dialog.data.width))
                        }
                        dialog:modify{
                            id = "height",
                            text = tostring(math.min(height,dialog.data.height))
                        }
                        --nClock = os.clock()
                        scaler:kCenter(dialog.data.width, dialog.data.height, dialog.data.centroids, dialog.data.accuracy)
                        --print("Elapsed time is: " .. os.clock()-nClock)
                        dRatio = dialog.data.ratio
                        dialog:close()
                    end
                }
                :button{text = "Cancel"}
                dialog:show{wait = false}
            end
        end
    }
    
end

function exit(plugin)
end