import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/report_provider.dart';
import '../../widgets/bottom_nav.dart';
import '../../services/report_pdf.dart';
import 'package:go_router/go_router.dart'; 
class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  int _selectedWeek = 1;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _init() async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null || auth.token == null) return;
    await context.read<ReportProvider>().loadUserWeeks(auth.user!.id, auth.token!);
    await _loadWeek(1);
  }

    // cuenta hacia adelante desde la primera fecha del usuario
    (DateTime, DateTime) _weekDates(int week) {
      final firstDate = context.read<ReportProvider>().userFirstDate;
      // Si no hay firstDate, usa la semana actual como fallback
      final base = firstDate ?? DateTime.now().subtract(
        Duration(days: DateTime.now().weekday - 1)
      );
      // Ajusta al lunes de la semana base
      final firstMonday = base.subtract(Duration(days: base.weekday - 1));
      final start = firstMonday.add(Duration(days: (week - 1) * 7));
      final end = start.add(const Duration(days: 6));
      return (start, end);
    }

  Future<void> _loadWeek(int week) async {
    final auth = context.read<AuthProvider>();
    if (auth.user == null || auth.token == null) return;
    final (start, end) = _weekDates(week);
    await context.read<ReportProvider>().loadReport(
      auth.user!.id,
      auth.token!,
      start,
      end,
    );
  }

  String _weekRange(int week) {
    final (start, end) = _weekDates(week);
    const months = [
      '', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
      'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic'
    ];
    return '${months[start.month]} ${start.day} – ${months[end.month]} ${end.day}, ${end.year}';
  }

  @override
  Widget build(BuildContext context) {
    final reportProvider = context.watch<ReportProvider>();
    final report = reportProvider.report;
    final totalWeeks = reportProvider.totalWeeks;

    return Scaffold(
      backgroundColor: const Color(0xFF1A1A1A),
      body: Column(
        children: [
          // Header oscuro
          Container(
            color: const Color(0xFF1A1A1A),
            padding: const EdgeInsets.fromLTRB(24, 56, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Título + campana
               Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Mis reportes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    IconButton(                                                        
                      onPressed: () => context.push('/reminders'),                
                      icon: const Icon(Icons.notifications_outlined, color: Colors.white), 
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                // Barra de búsqueda
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF2C2C2C),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TextField(
                      controller: _searchController,
                      style: const TextStyle(color: Colors.white),
                      keyboardType: TextInputType.number,        
                      onChanged: (v) {
                      final week = int.tryParse(v.trim());
                      if (week != null && week >= 1) {
                        setState(() => _selectedWeek = week);
                        _loadWeek(week);  // si no hay datos, simplemente mostrará todo en 0
                      }
                    },
                      decoration: InputDecoration(
                        hintText: 'Buscar semana...',
                        hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
                        prefixIcon: Icon(Icons.search, color: Colors.grey[500], size: 20),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                ),
                const SizedBox(height: 16),
                // Selector dinámico de semanas con scroll horizontal
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(totalWeeks, (i) {
                      final w = i + 1;
                      final selected = _selectedWeek == w;
                      return GestureDetector(
                        onTap: () {
                          setState(() => _selectedWeek = w);
                          _loadWeek(w);
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: i < totalWeeks - 1 ? 8 : 0),
                          padding: const EdgeInsets.symmetric(
                              vertical: 10, horizontal: 16),
                          decoration: BoxDecoration(
                            color: selected
                                ? const Color(0xFF4CAF50)
                                : const Color(0xFF2C2C2C),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            'Sem $w',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: selected ? Colors.white : Colors.grey[400],
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),

          // Contenido del reporte
          Expanded(
            child: reportProvider.isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                        color: Color(0xFF4CAF50)))
                : RefreshIndicator(
                    onRefresh: () => _loadWeek(_selectedWeek),
                    color: const Color(0xFF4CAF50),
                    child: SingleChildScrollView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Rango de semana
                          Text(
                            'Semana $_selectedWeek (${_weekRange(_selectedWeek)})',
                            style: TextStyle(
                                color: Colors.grey[400], fontSize: 13),
                          ),
                          const SizedBox(height: 16),

                          // Título + botón descargar
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Reporte Semanal',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              ElevatedButton.icon(
                               onPressed: () async {
                                  if (report == null) return;
                                  await downloadReportPdf(
                                    report,
                                    _selectedWeek,
                                    _weekRange(_selectedWeek),
                                  );
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF4CAF50),
                                  shape: RoundedRectangleBorder(
                                      borderRadius:
                                          BorderRadius.circular(20)),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 14, vertical: 8),
                                  elevation: 0,
                                ),
                                icon: const Icon(Icons.download,
                                    color: Colors.white, size: 16),
                                label: const Text('Descargar',
                                    style: TextStyle(
                                        color: Colors.white, fontSize: 13)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Tarjetas de macros
                          Row(
                            children: [
                              _nutrientCard(
                                  '${report?.avgProtein.toInt() ?? 0}g',
                                  'Proteína'),
                              const SizedBox(width: 10),
                              _nutrientCard(
                                  '${report?.avgCarbs.toInt() ?? 0}g',
                                  'Carbos'),
                              const SizedBox(width: 10),
                              _nutrientCard(
                                  '${report?.avgFat.toInt() ?? 0}g',
                                  'Grasas'),
                            ],
                          ),
                          const SizedBox(height: 16),

                          // Gráfica de barras
                          _buildBarChart(report?.dailyCalories ?? []),
                          const SizedBox(height: 16),

                          // Cumplimiento
                          _buildComplianceCard(
                              report?.compliancePercent ?? 0),
                          const SizedBox(height: 16),

                          // Datos clave
                          const Text(
                            'Datos clave',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: const Color(0xFF2C2C2C),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                    child: _keyData(
                                        '${report?.compliancePercent.toInt() ?? 0}%',
                                        'Cumplimiento',
                                        Icons.percent)),
                                Expanded(
                                    child: _keyData(
                                        '${report?.avgCalories.toInt() ?? 0}',
                                        'Prom. kcal',
                                        Icons.local_fire_department)),
                                Expanded(
                                    child: _keyData(
                                        '${report?.totalExtras ?? 0}',
                                        'Extras',
                                        Icons.warning_amber)),
                                Expanded(
                                    child: _keyData(
                                        '${report?.consecutiveDays ?? 0}',
                                        'Días consec.',
                                        Icons.calendar_today)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
          ),
        ],
      ),
      bottomNavigationBar: const BottomNav(currentIndex: 3),
    );
  }

  Widget _nutrientCard(String value, String label) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF2C2C2C),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          children: [
            Text(value,
                style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            Text(label,
                style: TextStyle(color: Colors.grey[400], fontSize: 12)),
          ],
        ),
      ),
    );
  }

  Widget _buildBarChart(List<Map<String, dynamic>> dailyData) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    const labels = ['Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb', 'Dom'];

    Map<String, double> caloriesMap = {};
    for (var d in dailyData) {
      caloriesMap[d['day']] = (d['calories'] as num).toDouble();
    }

    final maxCal = caloriesMap.values.isEmpty
        ? 200.0
        : caloriesMap.values.reduce((a, b) => a > b ? a : b);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Calorías Totales',
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.white),
          ),
          const SizedBox(height: 20),
          SizedBox(
            height: 140,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (i) {
                final cal = caloriesMap[days[i]] ?? 0;
                final barH = maxCal > 0 ? (cal / maxCal * 90) : 0;

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (cal > 0)
                      Text(
                        cal.toInt().toString(),
                        style:
                            TextStyle(color: Colors.grey[400], fontSize: 9),
                      ),
                    const SizedBox(height: 4),
                    Container(
                      width: 26,
                      height: barH.clamp(4.0, 90.0).toDouble(),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF9A9A),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      labels[i],
                      style: TextStyle(fontSize: 11, color: Colors.grey[500]),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComplianceCard(double percent) {
    Color statusColor;
    String statusText;
    if (percent >= 80) {
      statusColor = const Color(0xFF4CAF50);
      statusText = '¡Excelente cumplimiento!';
    } else if (percent >= 50) {
      statusColor = Colors.orange;
      statusText = 'Buen progreso';
    } else {
      statusColor = Colors.red;
      statusText = 'Necesitas mejorar';
    }

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            height: 80,
            child: Stack(
              alignment: Alignment.center,
              children: [
                CircularProgressIndicator(
                  value: percent / 100,
                  strokeWidth: 8,
                  backgroundColor: Colors.grey[700],
                  valueColor: AlwaysStoppedAnimation<Color>(statusColor),
                ),
                Text(
                  '${percent.toInt()}%',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 20),
          Container(width: 1, height: 50, color: Colors.grey[700]),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.emoji_events, size: 32, color: statusColor),
              const SizedBox(height: 6),
              Text(
                statusText,
                style: TextStyle(
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _keyData(String value, String label, IconData icon) {
    return Column(
      children: [
        Icon(icon, color: Colors.grey[400], size: 20),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        Text(label,
            style: TextStyle(color: Colors.grey[400], fontSize: 10),
            textAlign: TextAlign.center),
      ],
    );
  }
}