classdef Hyperplane
    properties
        Normal;
        Scalar;
    end
    properties (SetAccess = protected)
        dim
    end
    methods
        function hp = Hyperplane(normal, scalar)
            %HYPERPLANE Construct a hyperplane.
            %   A hyperplane is defined as the set {x\in R^n | N'*x = b}
            %   where N\in R^n is the normal vector and b\in R is the
            %   scalar.
            %
            % INPUTS
            %   - normal: <nx1 double> normal vector.
            %   - scalar: <1x1 double> scalar.
            %       normal and scalar represent N and b respectively in
            %       {x\in R^n | N'*x = b}.
            %
            % OUTPUTS
            %   - hp: <1x1 Hyperplane> hyperplane object.
            %
            % AUTHOR
            %   Mazen Azzam, University of Limerick, Lero - The Irish
            %   Software Research Centre.
            
            if size(normal,2) ~= 1
                error('Hyperplane normal must be of dimension n x 1.');
            end
            if size(scalar,1) > 1 || size(scalar,2) > 1
                error('Second argument to the Hyperplane constructor must be a scalar.');
            end
            
            hp.Normal = normal;
            hp.Scalar = scalar;
            hp.dim = length(normal);
        end
        function n = get.dim(hp)            
            % Getter function for Hyperplane dimension.

            n = hp.dim;
        end
        
        function isinhp = contains(hp, point)
            %CONTAINS Check whether a point belongs to a hyperplane.
            %
            % INPUTS
            %   - hp: <1x1 Hyperplane> hyperplane object.
            %   - point: <nx1 double> MATLAB vector representing the point
            %   to be checked. Must be the same dimension as hp.
            %
            % OUTPUTS
            %   - isinhp: <1x1 bool> 1 = point \in hp; 0 otherwise.
            %
            % AUTHOR
            %   Mazen Azzam, University of Limerick, Lero - The Irish
            %   Software Research Centre.
            
            assert(size(point,2) == 1);
            assert(hp.dim == length(point));
            isinhp = (dot(hp.Normal, point) == hp.Scalar);
        end
        
        function [center, shapemat] = hp2ell(hp, ell)
            %HP2ELL (deprecated) Convert a hyperplane to its corresponding
            %ellipsoid representation. Used to approximate intersection of
            %ellipsoid and hyperplane when employing Kurzhanskiy's[1]
            %method. No longer used since we are using Dai's [2] method.
            %
            % REFERENCES
            %   [1] Kurzhanskiy, 2006: The Ellipsoidal Toolbox.
            %   [2] Dai, 2012. An ellipsoid-based, two-stage screening test
            %   for BPDN. (20th European Signal Processing Conference).
            
            maxeig = max(eig(ell.Shape));
            center = (-hp.Scalar + 2*sqrt(maxeig))*(-hp.Normal);
            shapemat = (1/(4*maxeig))*hp.Normal*hp.Normal';
            
        end
        function dist = distance(hp, point)
            %DISTANCE Distance from a point to a hyperplane.
            
            dist = abs(hp.Normal'*point - hp.Scalar)/norm(hp.Normal);
        end
    end
    
end