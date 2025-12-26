package ar.com.digipad.yolov8tflite

import android.content.Context
import android.graphics.Canvas
import android.graphics.Color
import android.graphics.Paint
import android.util.AttributeSet
import android.view.View
import kotlin.math.max

class OverlayView(context: Context?, attrs: AttributeSet?) : View(context, attrs) {

    private var results = listOf<BoundingBox>()
    
    // Only one paint needed now for the main circle
    private var circlePaint = Paint()

    init {
        initPaints()
    }

    fun clear() {
        initPaints()
        invalidate()
    }

    private fun initPaints() {
        // Change to Green Opaque (Filled)
        circlePaint.color = Color.GREEN 
        circlePaint.style = Paint.Style.FILL // FILL makes it an "opaque" solid circle
        circlePaint.isAntiAlias = true
        
        // Optional: If you want it slightly transparent (like a lens), uncomment below:
        circlePaint.alpha = 150 
    }

    override fun draw(canvas: Canvas) {
        super.draw(canvas)

        // 1. Calcular tamaño promedio para los ojos para que sean iguales
        val eyes = results.filter { 
            it.clsName.contains("eye", ignoreCase = true) || 
            it.clsName.contains("pupil", ignoreCase = true) 
        }

        var avgEyeRadius = 0f
        if (eyes.isNotEmpty()) {
            val sumRadius = eyes.sumOf { 
                max((it.w * width) / 2, (it.h * height) / 2).toDouble() 
            }
            avgEyeRadius = (sumRadius / eyes.size).toFloat()
        }

        results.forEach {
            val cx = (it.cx * width).toFloat()
            val cy = (it.cy * height).toFloat()
            val isEye = it.clsName.contains("eye", ignoreCase = true) || 
                        it.clsName.contains("pupil", ignoreCase = true)

            // Si es ojo, usa el promedio. Si no (referencia), usa su tamaño real.
            val radius = if (isEye && avgEyeRadius > 0) avgEyeRadius 
                         else max((it.w * width) / 2, (it.h * height) / 2)

            // Draw the green filled circle
            canvas.drawCircle(cx, cy, radius, circlePaint)
            
            // Middle dot code removed here
        }
    }

    fun setResults(boundingBoxes: List<BoundingBox>) {
        results = boundingBoxes
        invalidate()
    }
}