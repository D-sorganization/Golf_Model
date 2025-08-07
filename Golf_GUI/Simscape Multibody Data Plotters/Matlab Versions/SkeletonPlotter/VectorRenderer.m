classdef VectorRenderer
    %VECTORRENDERER Helper utilities for rendering vector quivers.
    methods (Static)
        function updateQuiver(hQuiver, origin, vector, scaleFactor, isVisible)
            %UPDATEQUIVER Update position and visibility of a quiver3 handle.
            if ~ishandle(hQuiver); return; end
            vectorNorm = norm(vector);
            if any(isnan(origin)) || any(isinf(origin)) || any(isnan(vector)) || any(isinf(vector)) || ...
               isnan(scaleFactor) || isinf(scaleFactor) || vectorNorm < 1e-9 || abs(scaleFactor) < 1e-9
                set(hQuiver, 'Visible', 'off', 'XData', NaN, 'YData', NaN, 'ZData', NaN, ...
                    'UData', NaN, 'VData', NaN, 'WData', NaN);
                return;
            end
            if ~isVisible
                set(hQuiver, 'Visible', 'off');
                return;
            end
            set(hQuiver, 'Visible', 'on', ...
                'XData', origin(1), 'YData', origin(2), 'ZData', origin(3), ...
                'UData', vector(1) * scaleFactor, 'VData', vector(2) * scaleFactor, 'WData', vector(3) * scaleFactor);
        end
    end
end
