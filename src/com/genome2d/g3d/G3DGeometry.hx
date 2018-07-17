package com.genome2d.g3d;

import com.genome2d.debug.GDebug;

class G3DGeometry extends G3DNode {

	public var importedUvs:Array<Float>;
	public var importedIndices:Array<UInt>;
	public var importedUvIndices:Array<Int>;
	public var importedNormals:Array<Float>;
	
    public var vertices:Array<Float>;
    public var indices:Array<UInt>;
    public var uvs:Array<Float>;
    public var normals:Array<Float>;

    public function new(p_id:String) {
        super(p_id);
	}
	
	public function initProcessed(p_vertices:Array<Float>, p_uvs:Array<Float>, p_indices:Array<UInt>, p_normals:Array<Float>) {
        vertices = p_vertices;
		uvs = p_uvs;
		indices = p_indices;
		normals = p_normals;
    }
	
	public function initImported(p_vertices:Array<Float>, p_uvs:Array<Float>, p_indices:Array<UInt>, p_uvIndices:Array<Int>, p_normals:Array<Float>) {
		importedUvs = p_uvs;
		importedIndices = p_indices;
		importedUvIndices = p_uvIndices;
        importedNormals = p_normals;
		
		// TODO: assuming that reindexation happens if there is length disparity is a hack, potentionally reindexation should happen even if the length is the same but order doesn't match - sHTiF
		var reindexNormals:Bool = p_normals.length != importedIndices.length*3;
		normals = reindexNormals ? new Array<Float>() : p_normals;
		
        if (p_uvIndices.length != p_indices.length) throw "Not same number of vertex and UV indices!";

		vertices = new Array<Float>();
        uvs = new Array<Float>();
        indices = new Array<UInt>();
        for (j in 0...p_indices.length) {
            var vertexIndex:Int = p_indices[j];
            if (vertexIndex < 0) vertexIndex = -vertexIndex - 1;
			vertices.push(p_vertices[vertexIndex * 3]);
			vertices.push(p_vertices[vertexIndex * 3 + 1]);
			vertices.push(p_vertices[vertexIndex * 3 + 2]);
			if (reindexNormals) {
				normals.push(p_normals[vertexIndex * 3]);
				normals.push(p_normals[vertexIndex * 3 + 1]);
				normals.push(p_normals[vertexIndex * 3 + 2]);
			}
            indices.push(j);

            var uvIndex:Int = p_uvIndices[j];
            uvs.push(p_uvs[uvIndex * 2]);
            uvs.push(1 - p_uvs[uvIndex * 2 + 1]);
        }

		/*
        if (vertexNormals == null) {
            calculateFaceNormals();
            calculateVertexNormals();
        }
		/**/
    }
	
	/*
    private function calculateFaceNormals():Void {
        faceNormals = new Array<Float>();
        var i:Int = 0;
        while (i<indices.length) {
            var p1x:Float = vertices[indices[i]*3];
            var p1y:Float = vertices[indices[i]*3+1];
            var p1z:Float = vertices[indices[i]*3+2];
            var p2x:Float = vertices[indices[i+1]*3];
            var p2y:Float = vertices[indices[i+1]*3+1];
            var p2z:Float = vertices[indices[i+1]*3+2];
            var p3x:Float = vertices[indices[i+2]*3];
            var p3y:Float = vertices[indices[i+2]*3+1];
            var p3z:Float = vertices[indices[i+2]*3+2];
            var e1x:Float = p1x-p2x;
            var e1y:Float = p1y-p2y;
            var e1z:Float = p1z-p2z;
            var e2x:Float = p3x-p2x;
            var e2y:Float = p3y-p2y;
            var e2z:Float = p3z-p2z;
            var nx:Float = -e1y*e2z + e1z*e2y;
            var ny:Float = -e1z*e2x + e1x*e2z;
            var nz:Float = -e1x*e2y + e1y*e2x;
            var nl:Float = Math.sqrt(nx*nx+ny*ny+nz*nz);
            nx /= nl;
            ny /= nl;
            nz /= nl;
            faceNormals.push(nx);
            faceNormals.push(ny);
            faceNormals.push(nz);
            i+=3;
        }
    }

    private function getVertexFaces(p_vertexIndex:UInt):Array<UInt> {
        var faces:Array<UInt> = new Array<UInt>();
        for (i in 0...indices.length) {
            if (indices[i] == p_vertexIndex) {
                var face:UInt = Std.int(i/3);
                if (faces.indexOf(face) == -1) faces.push(face);
            }
        }
        return faces;
    }

    private function calculateVertexNormals():Void {
        normals = new Array<Float>();
        var vertexCount:Int = Std.int(vertices.length/3);
        for (i in 0...vertexCount) {
            var sharedFaces:Array<UInt> = getVertexFaces(i);
            var nx:Float = 0;
            var ny:Float = 0;
            var nz:Float = 0;
            for (faceIndex in sharedFaces) {
                nx += faceNormals[faceIndex*3];
                ny += faceNormals[faceIndex*3+1];
                nz += faceNormals[faceIndex*3+2];
            }
            var nl:Float = Math.sqrt(nx*nx+ny*ny+nz*nz);
            normals.push(nx/nl);
            normals.push(ny/nl);
            normals.push(nz/nl);
        }
    }
	/**/
}
