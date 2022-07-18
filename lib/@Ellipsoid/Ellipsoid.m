classdef Ellipsoid
    properties
       Center;
       Shape;
    end
    properties (SetAccess = private)
       dim; 
    end
    
    methods
        function ell = Ellipsoid(center, shape)
            %ELLIPSOID Construct an ellipsoid.
            %   The construction of the ellipsoid is based on the
            %   definition that an ellipsoid of center q and shape matrix
            %   Q>0 is the set {x \in \R^n | (x-q)'Q^(-1)(x-q) <= 1}. All
            %   of the geometric methods defined in this class are based on
            %   this characterisation.
            %   
            % INPUTS
            %    - center:   <nx1 double> vector
            %    - shape:    <nxn double> matrix (must be positive
            %       definite). 
            %       center and shape represent q and Q respectively in
            %       {x \in \R^n | (x-q)'Q^(-1)(x-q) <= 1}.
            %
            % OUTPUTS
            %    - ell: Ellipsoid object
            %
            % AUTHOR
            %   Mazen Azzam, University of Limerick, Lero - The Irish
            %   Software Research Centre.
            
            if ~issymmetric((shape+shape')./2)
                error('Shape matrix must be symmetric.');
            end
            if min(eig(shape)) < -1e-3
                error('Shape matrix must be positive definite.');
            end
            dim = length(center);
            if dim ~= size(shape,1)
                error('Shape matrix and center must be of the same dimension.');
            end
            ell.Center = center;
            ell.Shape = shape;
            ell.dim = dim;
            
        end
        
        function n = get.dim(ell)
            % Getter function for Ellipsoid dimension.
            
            n = ell.dim;
        end
        
        function vol = volume(ell)
            %VOLUME Compute ellipsoid volume.
            %
            % INPUTS
            %   ell: <1x1 Ellipsoid> ellipsoid.
            %
            % OUTPUTS
            %   vol: <1x1 double> ellipsoid's volume.
            %
            % AUTHOR
            %   Mazen Azzam, University of Limerick, Lero - The Irish
            %   Software Research Centre.
            %
            % REFERENCES
            %   [1] Kurzhanskiy, 2006: The Ellipsoidal Toolbox.
            
            
            if rem(ell.dim, 2) == 0
                vol = (pi^(ell.dim/2)/factorial(ell.dim/2))*sqrt(det(ell.Shape));
            else
                vol = (2^ell.dim * pi^((ell.dim-1)/2)*factorial((ell.dim-1)/2)/factorial(ell.dim))*sqrt(det(ell.Shape));
            end
        end
        
        function dist = distance(ell, obj, scale)
            %DISTANCE Distance between ellipsoid and a geometric object.
            %Currently only hyperplanes, defined by the Hyperplane object,
            %are supported.
            %
            % INPUTS
            %   - ell: <1x1 Ellipsoid> ellipsoid.
            %   - obj: geometric object of appropriate class. Supported
            %   classes:
            %       - <1x1 Hyperplane> (see help Hyperplane).
            %   - (optional) scale: <1x1 double> scaling factor
            %   to avoid numerical problems with large dimensions. The
            %   scale is used only when the EWS/Suspicion scheme needs to
            %   compute the volume ratio but the matrix determinant leads
            %   to NaN or zero due to numerical limitations.
            %
            % OUTPUTS
            %   - dist: <1x1 double> distance from ellipsoid to desired
            %   object.
            %
            % AUTHOR
            %   Mazen Azzam, University of Limerick, Lero - The Irish
            %   Software Research Centre.
            %
            % REFERENCES
            %   [1] Kurzhanskiy, 2006: The Ellipsoidal Toolbox.
            
             
            if nargin < 3
                scale = 1;
            elseif scale <= 0
                error('Scale must be a positive real number.');
            end
            if isa(obj, 'Hyperplane')
                if ell.dim ~= obj.dim
                    error('Ellipsoid and Hyperplane must be of the same dimension.');
                end
                % Remove the scale to get correct distance values.
                dist = ( abs(obj.Scalar - dot(obj.Normal, ell.Center)) - sqrt(dot(obj.Normal, (ell.Shape./scale)*obj.Normal)) )/( sqrt(dot(obj.Normal,obj.Normal)) );
            end
        end

        function intell = intersectex(ell, hp)
            %INTERSECTEX Get the ellipsoidal approximation of the
            %intersection of the ellipsoid with the halfspace delimited by
            %the hyperplane.
            %
            %   It is assumed that the hyperplane hp (hp.Normal, hp.Scalar)
            %   defines the halfpace given as: {x \in \R^n | hp.Normal'*x
            %   <= hp.Scalar}. For the "other side" of the halfspace, i.e.
            %   >= inequality, define the hyperplane with -hp.Normal and
            %   -hp.Scalar.
            %   This function approximates the intersection of an ellipsoid
            %   and a half-space as an external ellipsoid bounding the
            %   intersection. This implementation is based on the results
            %   in [1].
            %
            % INPUTS
            %   - ell: (1x1 Ellipsoid) ellipsoid.
            %   - hp:  (1x1 Hyperplane) hyperplane delimiting the
            %   halfspace.
            %
            % OUTPUTS
            %   - intell: (1x1 Ellipsoid) ellipsoid approximation of the
            %   intersection of ell and the halfspace delimited by hp.
            %
            % AUTHOR
            %   Mazen Azzam, University of Limerick, Lero - The Irish
            %   Software Research Centre.
            %
            % REFERENCES
            %   [1] Dai, 2012. An ellipsoid-based, two-stage screening test
            %   for BPDN. (20th European Signal Processing Conference).
            
            
            % Transform the hyperplane into the g^T(z - zp) + h <= 0
            % representation: (h = hpscalar)
            tic;
            hpscalar = hp.Normal'*ell.Center - hp.Scalar;
            hpnormal_norm = sqrt(hp.Normal'*ell.Shape*hp.Normal);
            alpha = hpscalar/hpnormal_norm;
            hpnormal = hp.Normal./hpnormal_norm;
            
            intcenter = ell.Center - ((1+alpha*ell.dim)/(ell.dim+1))*ell.Shape*hpnormal;
            intshape = ((ell.dim^2*(1-alpha^2))/(ell.dim^2-1))*(ell.Shape - ((2*(1+alpha*ell.dim))/((ell.dim+1)*(alpha+1)))*ell.Shape*(hpnormal*hpnormal')*ell.Shape);
            if ~issymmetric(intshape)
                intshape = 0.5*(intshape + intshape');
            end
            intell = Ellipsoid(intcenter, intshape);
        end
        function ellproj = project(ell, indproj)
            
            % Modify the ellipsoid's shape matrix according to the indices in indproj so we can manipulate it.
            ellshape = ell.Shape;
            indnotproj = zeros(1,ell.dim - length(indproj) );
            j = 1;
            for i = 1:ell.dim
                if isempty(find(indproj == i,1))
                    indnotproj(j) = i;
                    j = j+1;
                end
            end
            temp = inv(ellshape);
            ellshape(1:length(indproj),:) = temp(indproj,:);
            ellshape((length(indproj)+1):end,:) = temp(indnotproj,:);
            
            % Projection
            n = length(indproj);
            %ellshape = inv(ellshape);
            ellprojshape = ellshape(1:n,1:n) - ellshape(1:n,(n+1):end)*inv(ellshape((n+1):end,(n+1):end))*ellshape(1:n,(n+1):end)';
            
            ellproj = Ellipsoid(zeros(length(indproj),1),inv(ellprojshape));
        end
    end
    
    
end