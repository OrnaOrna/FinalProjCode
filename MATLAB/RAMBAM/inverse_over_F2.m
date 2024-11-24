function inverse_matrix = inverse_over_F2(matrix)
    n = size(matrix, 1);
    
    % Augment the matrix with the identity matrix
    augmented_matrix = [matrix eye(n)];
    
    % Perform row operations to reduce to row-echelon form
    for i = 1:n
        % Find pivot
        pivot_row = find(augmented_matrix(i:end, i), 1) + i - 1;
        
        % Swap rows if necessary
        if pivot_row ~= i
            augmented_matrix([i pivot_row], :) = augmented_matrix([pivot_row i], :);
        end
        
        % Eliminate nonzero elements below the pivot
        for j = i+1:n
            if augmented_matrix(j, i)
                augmented_matrix(j, :) = mod(augmented_matrix(j, :) + augmented_matrix(i, :), 2);
            end
        end
    end
    
    % Perform back substitution to obtain reduced row-echelon form
    for i = n:-1:2
        for j = 1:i-1
            if augmented_matrix(j, i)
                augmented_matrix(j, :) = mod(augmented_matrix(j, :) + augmented_matrix(i, :), 2);
            end
        end
    end
    
    % Extract the inverse matrix
    inverse_matrix = augmented_matrix(:, n+1:end);
end