import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/ui_config_bloc.dart';
import '../configs/action_config.dart';
import '../configs/component_config.dart';

/// Enhanced SDUI Widget Builder with rich component library
class SduiWidgetBuilder {
  final BuildContext context;

  SduiWidgetBuilder(this.context);

  /// Build widget from component config
  Widget buildComponent(ComponentConfig component) {
    switch (component.type) {
    // Layout Components
      case 'header':
        return _buildHeader(component);
      case 'container':
        return _buildContainer(component);
      case 'row':
        return _buildRow(component);
      case 'column':
        return _buildColumn(component);
      case 'stack':
        return _buildStack(component);
      case 'spacer':
        return SizedBox(height: (component.props['height'] ?? 16.0).toDouble());
      case 'divider':
        return Divider(
          color: _parseColor(component.props['color'] ?? '#CCCCCC'),
          thickness: (component.props['thickness'] ?? 1.0).toDouble(),
        );

    // E-commerce Components
      case 'product_grid':
        return _buildProductGrid(component);
      case 'product_card':
        return _buildProductCard(component);
      case 'product_carousel':
        return _buildProductCarousel(component);
      case 'category_chips':
        return _buildCategoryChips(component);

    // Promotional Components
      case 'banner':
        return _buildBanner(component);
      case 'countdown_timer':
        return _buildCountdownTimer(component);
      case 'promo_badge':
        return _buildPromoBadge(component);
      case 'story_circle':
        return _buildStoryCircle(component);

    // Interactive Components
      case 'button':
        return _buildButton(component);
      case 'search_bar':
        return _buildSearchBar(component);
      case 'rating':
        return _buildRating(component);
      case 'toggle':
        return _buildToggle(component);

    // Media Components
      case 'image':
        return _buildImage(component);
      case 'video_player':
        return _buildVideoPlayer(component);
      case 'avatar':
        return _buildAvatar(component);

    // List Components
      case 'horizontal_list':
        return _buildHorizontalList(component);
      case 'testimonial_card':
        return _buildTestimonialCard(component);

    // Advanced Components
      case 'skeleton_loader':
        return _buildSkeletonLoader(component);
      case 'shimmer_card':
        return _buildShimmerCard(component);
      case 'animated_banner':
        return _buildAnimatedBanner(component);

      default:
        return _buildFallback(component);
    }
  }

  // ==================== LAYOUT COMPONENTS ====================

  Widget _buildHeader(ComponentConfig component) {
    final title = component.props['title'] ?? '';
    final subtitle = component.props['subtitle'];
    final alignment = component.props['alignment'] ?? 'left';
    final showIcon = component.props['showIcon'] ?? false;
    final iconName = component.props['icon'] ?? 'star';

    return Container(
      padding: EdgeInsets.all((component.style?['padding'] ?? 16.0).toDouble()),
      decoration: component.style?['backgroundColor'] != null
          ? BoxDecoration(
        color: _parseColor(component.style!['backgroundColor']),
        borderRadius: BorderRadius.circular(
            (component.style?['borderRadius'] ?? 0.0).toDouble()),
      )
          : null,
      child: Column(
        crossAxisAlignment: alignment == 'center'
            ? CrossAxisAlignment.center
            : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: alignment == 'center'
                ? MainAxisAlignment.center
                : MainAxisAlignment.start,
            children: [
              if (showIcon) ...[
                Icon(
                  _getIconData(iconName),
                  size: (component.style?['iconSize'] ?? 28.0).toDouble(),
                  color: _parseColor(component.style?['color'] ?? '#000000'),
                ),
                const SizedBox(width: 12),
              ],
              Flexible(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: (component.style?['fontSize'] ?? 32.0).toDouble(),
                    fontWeight: _parseFontWeight(component.style?['fontWeight'] ?? 'bold'),
                    color: _parseColor(component.style?['color'] ?? '#000000'),
                    letterSpacing: component.style?['letterSpacing']?.toDouble(),
                  ),
                ),
              ),
            ],
          ),
          if (subtitle != null) ...[
            SizedBox(height: (component.style?['subtitleSpacing'] ?? 8.0).toDouble()),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: (component.style?['subtitleSize'] ?? 16.0).toDouble(),
                color: _parseColor(component.style?['subtitleColor'] ?? '#666666'),
                fontWeight: _parseFontWeight(component.style?['subtitleWeight'] ?? 'normal'),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildContainer(ComponentConfig component) {
    return Container(
      width: component.style?['width']?.toDouble(),
      height: component.style?['height']?.toDouble(),
      padding: EdgeInsets.all((component.style?['padding'] ?? 0.0).toDouble()),
      margin: EdgeInsets.all((component.style?['margin'] ?? 0.0).toDouble()),
      decoration: BoxDecoration(
        color: component.style?['backgroundColor'] != null
            ? _parseColor(component.style!['backgroundColor'])
            : null,
        borderRadius: BorderRadius.circular((component.style?['borderRadius'] ?? 0.0).toDouble()),
        border: component.style?['borderColor'] != null
            ? Border.all(
          color: _parseColor(component.style!['borderColor']),
          width: (component.style?['borderWidth'] ?? 1.0).toDouble(),
        )
            : null,
        boxShadow: component.style?['elevation'] != null
            ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: (component.style!['elevation'] ?? 4.0).toDouble(),
            offset: const Offset(0, 2),
          ),
        ]
            : null,
      ),
      child: component.children != null && component.children!.isNotEmpty
          ? Column(
        children: component.children!.map((child) => buildComponent(child)).toList(),
      )
          : null,
    );
  }

  Widget _buildRow(ComponentConfig component) {
    return Padding(
      padding: EdgeInsets.all((component.style?['padding'] ?? 0.0).toDouble()),
      child: Row(
        mainAxisAlignment: _parseAlignment(component.props['alignment'] ?? 'start'),
        crossAxisAlignment: _parseCrossAxisForRow(component.props['crossAlignment'] ?? 'center'),
        children: component.children?.map((child) {
          final widget = buildComponent(child);
          final flex = child.props['flex'];
          return flex != null ? Expanded(flex: flex, child: widget) : widget;
        }).toList() ?? [],
      ),
    );
  }

  Widget _buildColumn(ComponentConfig component) {
    return Padding(
      padding: EdgeInsets.all((component.style?['padding'] ?? 0.0).toDouble()),
      child: Column(
        crossAxisAlignment: _parseCrossAlignment(component.props['alignment'] ?? 'start'),
        mainAxisAlignment: _parseMainAxisAlignment(component.props['mainAlignment'] ?? 'start'),
        children: component.children?.map((child) => buildComponent(child)).toList() ?? [],
      ),
    );
  }

  Widget _buildStack(ComponentConfig component) {
    return Stack(
      alignment: AlignmentDirectional.topStart,
      children: component.children?.map((child) => buildComponent(child)).toList() ?? [],
    );
  }

  // ==================== E-COMMERCE COMPONENTS ====================

  Widget _buildProductGrid(ComponentConfig component) {
    final products = component.props['products'] as List? ?? [];
    final columns = component.props['columns'] ?? 2;
    final spacing = (component.props['spacing'] ?? 16.0).toDouble();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.all(spacing),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: component.props['aspectRatio'] ?? 0.75,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
      ),
      itemCount: products.length,
      itemBuilder: (context, index) {
        final product = products[index];
        return _buildProductCardFromData(product, component.style);
      },
    );
  }

  Widget _buildProductCard(ComponentConfig component) {
    return _buildProductCardFromData(component.props, component.style);
  }

  Widget _buildProductCardFromData(Map<String, dynamic> data, Map<String, dynamic>? style) {
    final showRating = style?['showRating'] ?? true;

    return GestureDetector(
      onTap: () => _handleAction(ActionConfig(
        type: 'navigate',
        route: '/product',
        params: {'id': data['id']},
      )),
      child: Card(
        clipBehavior: Clip.antiAlias,
        elevation: (style?['elevation'] ?? 2.0).toDouble(),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular((style?['borderRadius'] ?? 12.0).toDouble()),
        ),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Product Image with badge
              Stack(
                children: [
                  Container(
                    height: (style?['imageHeight'] ?? 150.0).toDouble(),
                    width: double.infinity,
                    color: Colors.grey[200],
                    child: data['image_url'] != null
                        ? Image.network(
                      data['image_url'],
                      fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => const Icon(Icons.image, size: 64),
                    )
                        : const Icon(Icons.shopping_bag, size: 64),
                  ),
                  // New/Sale badge
                  if (data['badge'] != null)
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: data['badge'] == 'NEW' ? Colors.green : Colors.orange,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          data['badge'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  // Favorite button
                  if (style?['showFavorite'] ?? false)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 4,
                            ),
                          ],
                        ),
                        child: IconButton(
                          icon: Icon(
                            data['is_favorite'] == true ? Icons.favorite : Icons.favorite_border,
                            color: Colors.red,
                            size: 20,
                          ),
                          onPressed: () {
                            // Handle favorite toggle
                          },
                        ),
                      ),
                    ),
                ],
              ),
          
              Padding(
                padding: EdgeInsets.all((style?['contentPadding'] ?? 12.0).toDouble()),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Product Name
                    Text(
                      data['name'] ?? '',
                      style: TextStyle(
                        fontSize: (style?['titleSize'] ?? 16.0).toDouble(),
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
          
                    // Rating
                    if (showRating && data['rating'] != null)
                      Row(
                        children: [
                          const Icon(Icons.star, size: 14, color: Colors.amber),
                          const SizedBox(width: 4),
                          Text(
                            '${data['rating']} (${data['review_count'] ?? 0})',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
          
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProductCarousel(ComponentConfig component) {
    final products = component.props['products'] as List? ?? [];
    final height = (component.props['height'] ?? 280.0).toDouble();

    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: (component.style?['padding'] ?? 16.0).toDouble()),
        itemCount: products.length,
        itemBuilder: (context, index) {
          return Container(
            width: (component.props['cardWidth'] ?? 200.0).toDouble(),
            margin: EdgeInsets.only(right: (component.style?['spacing'] ?? 12.0).toDouble()),
            child: _buildProductCardFromData(products[index], component.style),
          );
        },
      ),
    );
  }

  Widget _buildCategoryChips(ComponentConfig component) {
    final categories = component.props['categories'] as List? ?? [];
    final selectedId = component.props['selectedId'];

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: (component.style?['padding'] ?? 16.0).toDouble()),
        itemCount: categories.length,
        itemBuilder: (context, index) {
          final category = categories[index];
          final isSelected = category['id'] == selectedId;

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              selected: isSelected,
              label: Text(category['name'] ?? ''),
              onSelected: (selected) {
                if (component.action != null) {
                  _handleAction(component.action!);
                }
              },
              backgroundColor: Colors.grey[200],
              selectedColor: _parseColor(component.style?['selectedColor'] ?? '#000000'),
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  // ==================== PROMOTIONAL COMPONENTS ====================

  Widget _buildBanner(ComponentConfig component) {
    return GestureDetector(
      onTap: component.action != null ? () => _handleAction(component.action!) : null,
      child: Container(
        height: (component.props['height'] ?? 200.0).toDouble(),
        margin: EdgeInsets.all((component.style?['margin'] ?? 16.0).toDouble()),
        decoration: BoxDecoration(
          color: _parseColor(component.style?['backgroundColor'] ?? '#FF6B6B'),
          borderRadius: BorderRadius.circular((component.style?['borderRadius'] ?? 16.0).toDouble()),
          image: component.props['imageUrl'] != null
              ? DecorationImage(
            image: NetworkImage(component.props['imageUrl']),
            fit: BoxFit.cover,
          )
              : null,
          gradient: component.props['imageUrl'] == null && component.style?['gradient'] != null
              ? _parseGradient(component.style!['gradient'])
              : null,
        ),
        child: Container(
          padding: EdgeInsets.all((component.style?['contentPadding'] ?? 24.0).toDouble()),
          alignment: _parseAlignmentGeometry(component.props['alignment'] ?? 'centerLeft'),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular((component.style?['borderRadius'] ?? 16.0).toDouble()),
            gradient: component.props['imageUrl'] != null
                ? LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: [
                Colors.black.withOpacity(0.6),
                Colors.transparent,
              ],
            )
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: component.props['alignment'] == 'center'
                ? CrossAxisAlignment.center
                : CrossAxisAlignment.start,
            children: [
              if (component.props['title'] != null)
                Text(
                  component.props['title'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (component.style?['titleSize'] ?? 28.0).toDouble(),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (component.props['subtitle'] != null) ...[
                SizedBox(height: (component.style?['subtitleSpacing'] ?? 8.0).toDouble()),
                Text(
                  component.props['subtitle'],
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: (component.style?['subtitleSize'] ?? 16.0).toDouble(),
                  ),
                ),
              ],
              if (component.props['buttonText'] != null) ...[
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: component.action != null ? () => _handleAction(component.action!) : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  ),
                  child: Text(component.props['buttonText']),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCountdownTimer(ComponentConfig component) {
    final endTime = component.props['end_time'] ?? '';
    final showIcon = component.props['showIcon'] ?? true;

    return Container(
      padding: EdgeInsets.all((component.style?['padding'] ?? 16.0).toDouble()),
      margin: EdgeInsets.all((component.style?['margin'] ?? 0.0).toDouble()),
      decoration: BoxDecoration(
        color: _parseColor(component.style?['backgroundColor'] ?? '#FF6B6B'),
        borderRadius: BorderRadius.circular((component.style?['borderRadius'] ?? 8.0).toDouble()),
        gradient: component.style?['gradient'] != null
            ? _parseGradient(component.style!['gradient'])
            : null,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (showIcon) ...[
            Icon(
              Icons.timer,
              color: Colors.white,
              size: (component.style?['iconSize'] ?? 24.0).toDouble(),
            ),
            const SizedBox(width: 8),
          ],
          Text(
            component.props['label'] ?? 'Flash Sale Ends Soon!',
            style: TextStyle(
              color: Colors.white,
              fontSize: (component.style?['fontSize'] ?? 18.0).toDouble(),
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            endTime,
            style: TextStyle(
              color: Colors.white,
              fontSize: (component.style?['fontSize'] ?? 18.0).toDouble(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPromoBadge(ComponentConfig component) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: (component.style?['paddingX'] ?? 12.0).toDouble(),
        vertical: (component.style?['paddingY'] ?? 6.0).toDouble(),
      ),
      decoration: BoxDecoration(
        color: _parseColor(component.style?['backgroundColor'] ?? '#FF4757'),
        borderRadius: BorderRadius.circular((component.style?['borderRadius'] ?? 16.0).toDouble()),
      ),
      child: Text(
        component.props['text'] ?? '',
        style: TextStyle(
          color: Colors.white,
          fontSize: (component.style?['fontSize'] ?? 12.0).toDouble(),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildStoryCircle(ComponentConfig component) {
    final stories = component.props['stories'] as List? ?? [];

    return SizedBox(
      height: 100,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: (component.style?['padding'] ?? 16.0).toDouble()),
        itemCount: stories.length,
        itemBuilder: (context, index) {
          final story = stories[index];
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: story['viewed'] == true
                        ? null
                        : const LinearGradient(
                      colors: [Color(0xFFFFD700), Color(0xFFFF6B6B)],
                    ),
                  ),
                  padding: const EdgeInsets.all(3),
                  child: Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: CircleAvatar(
                      backgroundImage: story['image_url'] != null
                          ? NetworkImage(story['image_url'])
                          : null,
                      child: story['image_url'] == null
                          ? const Icon(Icons.store)
                          : null,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                SizedBox(
                  width: 70,
                  child: Text(
                    story['name'] ?? '',
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ==================== INTERACTIVE COMPONENTS ====================

  Widget _buildButton(ComponentConfig component) {
    final label = component.props['label'] ?? 'Button';
    final variant = component.props['variant'] ?? 'primary';
    final fullWidth = component.props['fullWidth'] ?? false;
    final icon = component.props['icon'];

    final button = ElevatedButton(
      onPressed: component.action != null ? () => _handleAction(component.action!) : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: variant == 'primary'
            ? _parseColor(component.style?['backgroundColor'] ?? '#000000')
            : variant == 'outline'
            ? Colors.transparent
            : Colors.grey[200],
        foregroundColor: variant == 'primary'
            ? Colors.white
            : _parseColor(component.style?['color'] ?? '#000000'),
        padding: EdgeInsets.symmetric(
          horizontal: (component.style?['paddingX'] ?? 24.0).toDouble(),
          vertical: (component.style?['paddingY'] ?? 16.0).toDouble(),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular((component.style?['borderRadius'] ?? 8.0).toDouble()),
          side: variant == 'outline'
              ? BorderSide(color: _parseColor(component.style?['borderColor'] ?? '#000000'))
              : BorderSide.none,
        ),
        elevation: variant == 'text' ? 0 : (component.style?['elevation'] ?? 2.0).toDouble(),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(_getIconData(icon), size: 20),
            const SizedBox(width: 8),
          ],
          Text(
            label,
            style: TextStyle(
              fontSize: (component.style?['fontSize'] ?? 16.0).toDouble(),
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );

    return Padding(
      padding: EdgeInsets.all((component.style?['margin'] ?? 0.0).toDouble()),
      child: fullWidth ? SizedBox(width: double.infinity, child: button) : button,
    );
  }

  Widget _buildSearchBar(ComponentConfig component) {
    return Container(
      margin: EdgeInsets.all((component.style?['margin'] ?? 16.0).toDouble()),
      child: TextField(
        decoration: InputDecoration(
          hintText: component.props['placeholder'] ?? 'Search...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: component.props['showFilter'] == true
              ? IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {},
          )
              : null,
          filled: true,
          fillColor: _parseColor(component.style?['backgroundColor'] ?? '#F5F5F5'),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular((component.style?['borderRadius'] ?? 12.0).toDouble()),
            borderSide: BorderSide.none,
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: (component.style?['paddingX'] ?? 16.0).toDouble(),
            vertical: (component.style?['paddingY'] ?? 14.0).toDouble(),
          ),
        ),
      ),
    );
  }

  Widget _buildRating(ComponentConfig component) {
    final rating = (component.props['rating'] ?? 0.0).toDouble();
    final maxStars = component.props['maxStars'] ?? 5;
    final size = (component.style?['size'] ?? 20.0).toDouble();
    final showValue = component.props['showValue'] ?? true;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        ...List.generate(maxStars, (index) {
          return Icon(
            index < rating.floor()
                ? Icons.star
                : index < rating
                ? Icons.star_half
                : Icons.star_border,
            color: _parseColor(component.style?['color'] ?? '#FFD700'),
            size: size,
          );
        }),
        if (showValue) ...[
          const SizedBox(width: 8),
          Text(
            rating.toStringAsFixed(1),
            style: TextStyle(
              fontSize: size * 0.8,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildToggle(ComponentConfig component) {
    final value = component.props['value'] ?? false;

    return SwitchListTile(
      title: Text(component.props['label'] ?? ''),
      value: value,
      onChanged: (newValue) {
        if (component.action != null) {
          _handleAction(component.action!);
        }
      },
      activeColor: _parseColor(component.style?['activeColor'] ?? '#4CAF50'),
    );
  }

  // ==================== MEDIA COMPONENTS ====================

  Widget _buildImage(ComponentConfig component) {
    final url = component.props['url'];
    final width = component.style?['width']?.toDouble();
    final height = component.style?['height']?.toDouble();
    final fit = _parseBoxFit(component.style?['fit'] ?? 'cover');

    return Container(
      width: width,
      height: height,
      margin: EdgeInsets.all((component.style?['margin'] ?? 0.0).toDouble()),
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular((component.style?['borderRadius'] ?? 0.0).toDouble()),
      ),
      child: url != null
          ? Image.network(
        url,
        fit: fit,
        errorBuilder: (_, _, _) => Container(
          color: Colors.grey[300],
          child: const Icon(Icons.broken_image, size: 64),
        ),
      )
          : Container(
        color: Colors.grey[300],
        child: const Icon(Icons.image, size: 64),
      ),
    );
  }

  Widget _buildVideoPlayer(ComponentConfig component) {
    // Placeholder for video player
    return Container(
      height: (component.props['height'] ?? 200.0).toDouble(),
      margin: EdgeInsets.all((component.style?['margin'] ?? 0.0).toDouble()),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular((component.style?['borderRadius'] ?? 8.0).toDouble()),
      ),
      child: Center(
        child: Icon(
          Icons.play_circle_outline,
          size: 64,
          color: Colors.white.withOpacity(0.8),
        ),
      ),
    );
  }

  Widget _buildAvatar(ComponentConfig component) {
    final url = component.props['url'];
    final size = (component.style?['size'] ?? 50.0).toDouble();
    final name = component.props['name'] ?? '';

    return CircleAvatar(
      radius: size / 2,
      backgroundImage: url != null ? NetworkImage(url) : null,
      child: url == null
          ? Text(
        name.isNotEmpty ? name[0].toUpperCase() : '?',
        style: TextStyle(
          fontSize: size * 0.4,
          fontWeight: FontWeight.bold,
        ),
      )
          : null,
    );
  }

  // ==================== LIST COMPONENTS ====================

  Widget _buildHorizontalList(ComponentConfig component) {
    final items = component.props['items'] as List? ?? [];
    final height = (component.props['height'] ?? 120.0).toDouble();

    return SizedBox(
      height: height,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: EdgeInsets.symmetric(horizontal: (component.style?['padding'] ?? 16.0).toDouble()),
        itemCount: items.length,
        itemBuilder: (context, index) {
          final item = items[index];
          return Container(
            width: (component.props['itemWidth'] ?? 120.0).toDouble(),
            margin: EdgeInsets.only(right: (component.style?['spacing'] ?? 12.0).toDouble()),
            child: Card(
              clipBehavior: Clip.antiAlias,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (item['image_url'] != null)
                    Expanded(
                      child: Image.network(
                        item['image_url'],
                        fit: BoxFit.cover,
                        width: double.infinity,
                      ),
                    ),
                  Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(
                      item['title'] ?? '',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildTestimonialCard(ComponentConfig component) {
    return Card(
      margin: EdgeInsets.all((component.style?['margin'] ?? 16.0).toDouble()),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundImage: component.props['avatar_url'] != null
                      ? NetworkImage(component.props['avatar_url'])
                      : null,
                  child: component.props['avatar_url'] == null
                      ? const Icon(Icons.person)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        component.props['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      if (component.props['subtitle'] != null)
                        Text(
                          component.props['subtitle'],
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                    ],
                  ),
                ),
                _buildRating(ComponentConfig(
                  id: 'rating',
                  type: 'rating',
                  props: {'rating': component.props['rating'] ?? 5},
                  style: {'size': 16.0},
                )),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              component.props['text'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[800],
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== ADVANCED COMPONENTS ====================

  Widget _buildSkeletonLoader(ComponentConfig component) {
    final type = component.props['type'] ?? 'card';

    return Container(
      margin: EdgeInsets.all((component.style?['margin'] ?? 16.0).toDouble()),
      child: _buildSkeletonForType(type),
    );
  }

  Widget _buildSkeletonForType(String type) {
    final shimmerColor = Colors.grey[300]!;

    switch (type) {
      case 'card':
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(height: 200, color: shimmerColor),
            const SizedBox(height: 8),
            Container(height: 20, width: 150, color: shimmerColor),
            const SizedBox(height: 8),
            Container(height: 16, width: 100, color: shimmerColor),
          ],
        );
      case 'list':
        return Column(
          children: List.generate(3, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                Container(width: 60, height: 60, color: shimmerColor),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(height: 16, color: shimmerColor),
                      const SizedBox(height: 8),
                      Container(height: 14, width: 100, color: shimmerColor),
                    ],
                  ),
                ),
              ],
            ),
          )),
        );
      default:
        return Container(height: 100, color: shimmerColor);
    }
  }

  Widget _buildShimmerCard(ComponentConfig component) {
    return Card(
      margin: EdgeInsets.all((component.style?['margin'] ?? 8.0).toDouble()),
      child: Container(
        height: (component.props['height'] ?? 150.0).toDouble(),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.grey[300]!,
              Colors.grey[100]!,
              Colors.grey[300]!,
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAnimatedBanner(ComponentConfig component) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.0, end: 1.0),
      duration: Duration(milliseconds: (component.props['duration'] ?? 800)),
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 20 * (1 - value)),
            child: _buildBanner(component),
          ),
        );
      },
    );
  }

  // ==================== FALLBACK ====================

  Widget _buildFallback(ComponentConfig component) {
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.amber[100],
        border: Border.all(color: Colors.amber, width: 2),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning, color: Colors.orange),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Unknown component: ${component.type}',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  // ==================== ACTION HANDLERS ====================

  void _handleAction(ActionConfig action) {
    switch (action.type) {
      case 'navigate':
        if (action.route != null) {
          context.read<UiConfigBloc>().add(
            NavigateToScreen(
              screen: action.route!,
              params: action.params,
            ),
          );
        }
        break;

      case 'external_link':
      // Open URL
        break;

      case 'modal':
      // Show modal
        break;

      case 'toast':
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(action.params?['message'] ?? 'Action triggered')),
        );
        break;
    }
  }

  // ==================== UTILITY PARSERS ====================

  Color _parseColor(String colorString) {
    try {
      return Color(int.parse(colorString.replaceFirst('#', '0xFF')));
    } catch (e) {
      return Colors.black;
    }
  }

  FontWeight _parseFontWeight(String weight) {
    switch (weight) {
      case 'bold':
        return FontWeight.bold;
      case 'normal':
        return FontWeight.normal;
      case 'light':
        return FontWeight.w300;
      case 'medium':
        return FontWeight.w500;
      case 'semibold':
        return FontWeight.w600;
      default:
        return FontWeight.normal;
    }
  }

  MainAxisAlignment _parseAlignment(String alignment) {
    switch (alignment) {
      case 'start':
        return MainAxisAlignment.start;
      case 'center':
        return MainAxisAlignment.center;
      case 'end':
        return MainAxisAlignment.end;
      case 'spaceBetween':
        return MainAxisAlignment.spaceBetween;
      case 'spaceAround':
        return MainAxisAlignment.spaceAround;
      case 'spaceEvenly':
        return MainAxisAlignment.spaceEvenly;
      default:
        return MainAxisAlignment.start;
    }
  }

  MainAxisAlignment _parseMainAxisAlignment(String alignment) {
    return _parseAlignment(alignment);
  }

  CrossAxisAlignment _parseCrossAlignment(String alignment) {
    switch (alignment) {
      case 'start':
        return CrossAxisAlignment.start;
      case 'center':
        return CrossAxisAlignment.center;
      case 'end':
        return CrossAxisAlignment.end;
      case 'stretch':
        return CrossAxisAlignment.stretch;
      default:
        return CrossAxisAlignment.start;
    }
  }

  CrossAxisAlignment _parseCrossAxisForRow(String alignment) {
    return _parseCrossAlignment(alignment);
  }

  AlignmentGeometry _parseAlignmentGeometry(String alignment) {
    switch (alignment) {
      case 'topLeft':
        return Alignment.topLeft;
      case 'topCenter':
        return Alignment.topCenter;
      case 'topRight':
        return Alignment.topRight;
      case 'centerLeft':
        return Alignment.centerLeft;
      case 'center':
        return Alignment.center;
      case 'centerRight':
        return Alignment.centerRight;
      case 'bottomLeft':
        return Alignment.bottomLeft;
      case 'bottomCenter':
        return Alignment.bottomCenter;
      case 'bottomRight':
        return Alignment.bottomRight;
      default:
        return Alignment.centerLeft;
    }
  }

  BoxFit _parseBoxFit(String fit) {
    switch (fit) {
      case 'fill':
        return BoxFit.fill;
      case 'contain':
        return BoxFit.contain;
      case 'cover':
        return BoxFit.cover;
      case 'fitWidth':
        return BoxFit.fitWidth;
      case 'fitHeight':
        return BoxFit.fitHeight;
      default:
        return BoxFit.cover;
    }
  }

  LinearGradient _parseGradient(Map<String, dynamic> gradientConfig) {
    final colors = (gradientConfig['colors'] as List?)
        ?.map((c) => _parseColor(c.toString()))
        .toList() ??
        [Colors.blue, Colors.purple];

    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: colors,
    );
  }

  IconData _getIconData(String iconName) {
    switch (iconName) {
      case 'home':
        return Icons.home;
      case 'search':
        return Icons.search;
      case 'favorite':
      case 'heart':
        return Icons.favorite;
      case 'cart':
      case 'shopping_cart':
        return Icons.shopping_cart;
      case 'profile':
      case 'person':
        return Icons.person;
      case 'settings':
        return Icons.settings;
      case 'notifications':
        return Icons.notifications;
      case 'star':
        return Icons.star;
      case 'arrow_forward':
        return Icons.arrow_forward;
      case 'arrow_back':
        return Icons.arrow_back;
      case 'check':
        return Icons.check;
      case 'close':
        return Icons.close;
      case 'add':
        return Icons.add;
      case 'remove':
        return Icons.remove;
      case 'filter':
        return Icons.filter_list;
      case 'sort':
        return Icons.sort;
      default:
        return Icons.circle;
    }
  }
}